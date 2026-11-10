"""Lightweight, comment/string-aware lexical audit, not a Solidity compiler.

Source offsets refer to the original UTF-8-decoded text. Lexical validity does
not imply compilability, semantic correctness or absence of vulnerabilities.
"""
from __future__ import annotations

import re
from dataclasses import dataclass

TOKEN = re.compile(r'''(?:hex|unicode)?"(?:\\.|[^"\\])*"|(?:hex|unicode)?'(?:\\.|[^'\\])*'|[A-Za-z_$][\w$]*|0x[\da-fA-F]+|\d+(?:\.\d+)?|==|!=|<=|>=|&&|\|\||=>|\+\+|--|\+=|-=|\*\*|[^\s]''')


@dataclass
class Lexed:
    clean: str
    mask: str
    errors: list[str]
    comments: list[str]


def lex(text: str) -> Lexed:
    clean, masked = list(text), list(text)
    errors, comments = [], []
    i = 0
    while i < len(text):
        if text.startswith("//", i):
            end = text.find("\n", i)
            end = len(text) if end < 0 else end
            comments.append(text[i:end])
            for j in range(i, end):
                clean[j] = masked[j] = " "
            i = end
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end < 0:
                errors.append("unclosed_block_comment")
                end = len(text)
            else:
                end += 2
            comments.append(text[i:end])
            for j in range(i, end):
                if text[j] not in "\r\n":
                    clean[j] = masked[j] = " "
            i = end
        elif text[i] in "\"'":
            quote, start = text[i], i
            i += 1
            closed = False
            while i < len(text):
                if text[i] == "\\":
                    i += 2
                elif text[i] == quote:
                    i += 1
                    closed = True
                    break
                else:
                    i += 1
            if not closed:
                errors.append("unclosed_string")
            for j in range(start, min(i, len(text))):
                if text[j] not in "\r\n":
                    masked[j] = " "
        else:
            i += 1
    mask = "".join(masked)
    stack = []
    for char in mask:
        if char in "{([":
            stack.append(char)
        elif char in "})]":
            if not stack or stack.pop() != {"}": "{", ")": "(", "]": "["}[char]:
                errors.append("mismatched_delimiters")
                break
    if stack:
        errors.append("unclosed_delimiters")
    return Lexed("".join(clean), mask, sorted(set(errors)), comments)


DECLARATION = re.compile(r"\b(?:abstract\s+)?(contract|library|interface)\s+([A-Za-z_$][\w$]*)\b([^;{]*)\{")


def declarations(text: str, lexed: Lexed | None = None) -> list[dict]:
    result = []
    document = lexed or lex(text)
    for match in DECLARATION.finditer(document.mask):
        depth, end = 1, match.end()
        while end < len(text) and depth:
            depth += (document.mask[end] == "{") - (document.mask[end] == "}")
            end += 1
        if depth:
            continue
        # Nested matches inside an already discovered declaration are not units.
        if any(x["start"] <= match.start() < x["end"] for x in result):
            continue
        header = match.group(3)
        inherited = re.search(r"\bis\b(.*)", header, flags=re.S)
        inheritance = inherited.group(1) if inherited else ""
        # Split base clauses only at top-level commas, never constructor args.
        pieces, begin, level = [], 0, 0
        for pos, char in enumerate(inheritance):
            level += (char == "(") - (char == ")")
            if char == "," and level == 0:
                pieces.append(inheritance[begin:pos])
                begin = pos + 1
        pieces.append(inheritance[begin:])
        bases = []
        for piece in pieces:
            base = re.match(r"\s*([A-Za-z_$][\w$]*(?:\s*\.\s*[A-Za-z_$][\w$]*)*)", piece)
            if base:
                bases.append(re.sub(r"\s+", "", base.group(1)))
        result.append({"kind": match.group(1), "name": match.group(2),
                       "start": match.start(), "end": end, "bases": bases})
    return result


def tokenize(text: str) -> list[str]:
    return TOKEN.findall(text)


def canonical_tokens(text: str) -> list[str]:
    """For clone detection only: ignore pragma, identifier spelling and literals.

    The model will use the original code tokens, not these canonical tokens.
    """
    clean = re.sub(r"\bpragma\s+solidity\s+[^;]*;", "", lex(text).clean)
    keywords = set("abstract after alias apply assembly auto bool break byte bytes case catch constant constructor continue contract default delete do else emit enum event external false fallback final fixed for from function if immutable implements import in indexed inline int interface internal is let library mapping match memory modifier new null of override payable private promise public pure receive reference relocatable return returns sealed sizeof static storage string struct supports switch this throw true try type typeof ufixed uint unchecked using var view virtual while address assert require revert selfdestruct suicide call callcode delegatecall send transfer tx origin msg sender value block timestamp number balance now keccak256 sha256 ripemd160 ecrecover abi encode decode".split())
    result = []
    for token in tokenize(clean):
        if token[0] in "\"'" or token.startswith(('hex"', "hex'", 'unicode"', "unicode'")):
            result.append("STR")
        elif token[0].isdigit():
            result.append("NUM")
        elif re.fullmatch(r"[A-Za-z_$][\w$]*", token) and token not in keywords and not re.fullmatch(r"(?:u?int|bytes)\d+", token):
            result.append("ID")
        else:
            result.append(token)
    return result
