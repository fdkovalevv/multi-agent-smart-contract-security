"""Prepare contract scopes, tri-state labels and clone groups from CGT.

Descriptive statistics and code counters are calculated in the notebook.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path

import numpy as np
import pandas as pd

from download_cgt import COMMIT, download
from solidity_lex import canonical_tokens, declarations, lex, tokenize
from similarity import exact_jaccard_pairs

ROOT = Path(__file__).resolve().parents[1]
SWC_NAMES = {
    100: "Function Default Visibility", 101: "Integer Overflow / Underflow",
    102: "Outdated Compiler Version", 103: "Floating Pragma",
    104: "Unchecked Call Return Value", 105: "Unprotected Ether Withdrawal",
    106: "Unprotected SELFDESTRUCT", 107: "Reentrancy",
    108: "State Variable Default Visibility", 109: "Uninitialized Storage Pointer",
    110: "Assert Violation", 111: "Use of Deprecated Functions",
    112: "Delegatecall to Untrusted Callee", 113: "DoS with Failed Call",
    114: "Transaction Order Dependence", 115: "Authorization via tx.origin",
    116: "Block Timestamp Dependence", 117: "Signature Malleability",
    118: "Incorrect Constructor Name", 119: "Shadowing State Variables",
    120: "Weak Randomness", 123: "Requirement Violation",
    124: "Write to Arbitrary Storage Location", 125: "Incorrect Inheritance Order",
    126: "Insufficient Gas Griefing", 127: "Arbitrary Jump with Function Variable",
    128: "DoS with Block Gas Limit", 129: "Typographical Error",
    130: "Right-To-Left Override", 131: "Unused Variables",
    132: "Unexpected Ether Balance", 133: "Hash Collision",
    134: "Hardcoded Gas Amount", 135: "Code with No Effects",
    136: "Unencrypted Private Data", 995: "CGT: Short Address",
    996: "CGT: Honeypot", 997: "CGT: Locked Ether", 999: "CGT: Other Arithmetic",
}


class UnionFind:
    def __init__(self, items):
        self.parent = {x: x for x in items}

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, a, b):
        a, b = self.find(a), self.find(b)
        if a != b:
            self.parent[max(a, b)] = min(a, b)


def save_json(path: Path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False, default=str) + "\n")


def source_groups(rows: pd.DataFrame, texts: dict, root: Path) -> tuple[dict, pd.DataFrame]:
    uf = UnionFind(texts)
    edges = []

    def join_members(members, reason):
        members = sorted(set(members) & set(texts))
        for b in members[1:]:
            uf.union(members[0], b)
            edges.append({"a": members[0], "b": b, "reason": reason, "jaccard": None})

    valid = rows[rows.fp_sol.isin(texts)]
    for _, part in valid[valid.fp_sol2.ne("")].groupby("fp_sol2", sort=True):
        join_members(part.fp_sol, "same_fp_sol2")
    addr = valid[valid.addr.str.fullmatch(r"0x[0-9a-fA-F]{40}") & valid.chain.ne("")].copy()
    addr["address_key"] = addr.chain + ":" + addr.addr.str.lower()
    for _, part in addr.groupby("address_key", sort=True):
        join_members(part.fp_sol, "same_chain_address")
    # Different injection classes retain the original SolidiFI template number.
    synthetic = valid[valid.dataset.eq("SolidiFI")].copy()
    synthetic["template"] = synthetic.id.str.extract(
        r"^(?:Overflow-Underflow|Timestamp-Dependency|Unchecked-Send|Unhandled-Exceptions|Re-entrancy|TOD|tx\.origin)-(\d+)$",
        expand=False).fillna("")
    for _, part in synthetic[synthetic.template.ne("")].groupby("template", sort=True):
        join_members(part.fp_sol, "solidifi_template_id")
    shingle_sets = {}
    canonical_hashes = defaultdict(list)
    for index, fp in enumerate(sorted(texts)):
        tokens = canonical_tokens(texts[fp])
        canonical_hashes[hashlib.sha256(" ".join(tokens).encode()).hexdigest()].append(fp)
        shingles = {" ".join(tokens[i:i + 5]).encode() for i in range(max(0, len(tokens) - 4))}
        shingle_sets[fp] = shingles
        if (index + 1) % 500 == 0:
            print(f"Clone audit: {index + 1}/{len(texts)} sources", flush=True)
    print("Exact prefix-filtered Jaccard comparison", flush=True)
    for a, b, score in exact_jaccard_pairs({k: v for k, v in shingle_sets.items() if len(v) >= 20}, threshold=0.9):
        uf.union(a, b)
        edges.append({"a": a, "b": b, "reason": "canonical_5gram_jaccard_ge_0.90", "jaccard": score})
    for members in canonical_hashes.values():
        if len(members) > 1:
            join_members(members, "same_identifier_literal_normalized_tokens")
    groups = {fp: "g_" + uf.find(fp) for fp in texts}
    return groups, pd.DataFrame(edges, columns=["a", "b", "reason", "jaccard"])


def refine_groups_for_model_inputs(entities, groups, edges, root):
    """Also group identical/near-identical target scopes from different files.

    Whole-file similarity alone misses equal inputs surrounded by different code.
    """
    uf = UnionFind(groups)
    by_group = defaultdict(list)
    for fp, group in groups.items():
        by_group[group].append(fp)
    for members in by_group.values():
        for fp in members[1:]:
            uf.union(members[0], fp)
    by_hash = defaultdict(list)
    shingles, fp_for_entity, new_edges = {}, {}, []
    input_hashes, canonical_hashes = {}, {}
    for row in entities.itertuples(index=False):
        code = (root / row.model_input).read_text()
        regular = " ".join(tokenize(code))
        tokens = canonical_tokens(code)
        normal = " ".join(tokens)
        input_hashes[row.entity_id] = hashlib.sha256(regular.encode()).hexdigest()
        canonical_hashes[row.entity_id] = hashlib.sha256(normal.encode()).hexdigest()
        by_hash[canonical_hashes[row.entity_id]].append(row.fp_sol)
        values = {" ".join(tokens[i:i + 5]).encode() for i in range(max(0, len(tokens) - 4))}
        if len(values) >= 20:
            shingles[row.entity_id] = values
        fp_for_entity[row.entity_id] = row.fp_sol
    for members in by_hash.values():
        members = sorted(set(members))
        for fp in members[1:]:
            uf.union(members[0], fp)
            new_edges.append({"a": members[0], "b": fp, "reason": "same_canonical_model_input", "jaccard": None})
    for a, b, score in exact_jaccard_pairs(shingles, threshold=.9):
        fa, fb = fp_for_entity[a], fp_for_entity[b]
        if fa != fb:
            uf.union(fa, fb)
            new_edges.append({"a": fa, "b": fb, "reason": "model_input_5gram_jaccard_ge_0.90", "jaccard": score})
    final_groups = {fp: "g_" + uf.find(fp) for fp in groups}
    entities["group_id"] = entities.fp_sol.map(final_groups)
    entities["model_input_hash"] = entities.entity_id.map(input_hashes)
    entities["canonical_model_input_hash"] = entities.entity_id.map(canonical_hashes)
    combined = pd.concat([edges, pd.DataFrame(new_edges, columns=edges.columns)], ignore_index=True)
    return entities, final_groups, combined


def audit(root: Path = ROOT):
    download(root)  # Also verifies every SHA-256 without network on subsequent runs.
    raw = root / "data/raw/cgt"
    processed = root / "data/processed"
    for folder in (processed, processed / "model_inputs"):
        folder.mkdir(parents=True, exist_ok=True)
    previous_path = processed / "contracts.csv"
    previous = pd.read_csv(previous_path, keep_default_na=False).set_index("entity_id") if previous_path.exists() else None
    rows = pd.read_csv(raw / "consolidated.csv", sep=";", dtype=str, keep_default_na=False)
    expected = {"dataset", "id", "property", "property_holds", "chain", "addr", "contractname", "fp_sol", "fp_sol2", "fp_bytecode", "fp_runtime", "swc", "dasp"}
    if set(rows.columns) != expected:
        raise ValueError(f"Unexpected columns: {set(rows.columns) ^ expected}")
    raw_issues = []
    for column in ("dataset", "id", "property", "property_holds"):
        for index in rows.index[rows[column].eq("")]:
            raw_issues.append({"row": int(index), "issue": f"missing_required_{column}"})
    for index in rows.index[~rows.property_holds.isin(["t", "f"])]:
        raw_issues.append({"row": int(index), "issue": "invalid_property_holds"})
    duplicated = rows.duplicated(["dataset", "id", "property"], keep=False)
    for index in rows.index[duplicated]:
        raw_issues.append({"row": int(index), "issue": "duplicate_assessment_key"})
    for column in ("fp_sol", "fp_sol2", "fp_bytecode", "fp_runtime"):
        for index in rows.index[rows[column].ne("") & ~rows[column].str.fullmatch("[0-9a-f]{32}")]:
            raw_issues.append({"row": int(index), "issue": f"invalid_{column}"})
    for column, allowed in (("swc", set(range(100, 137)) | set(range(995, 1000))), ("dasp", set(range(1, 10)))):
        for index, value in rows[column].items():
            if value and (not value.isdigit() or int(value) not in allowed):
                raw_issues.append({"row": int(index), "issue": f"invalid_{column}"})
    if raw_issues:
        save_json(processed / "preparation_audit.json", {"commit": COMMIT, "invalid_rows": raw_issues})
        raise ValueError("Invalid input rows. See data/processed/preparation_audit.json")
    source_meta, texts, decls = [], {}, {}
    for path in sorted((raw / "source").glob("*.sol")):
        fp = path.stem
        content = path.read_bytes()
        try:
            code = content.decode("utf-8")
            decoding = "utf-8"
        except UnicodeDecodeError:
            code = content.decode("utf-8", errors="replace")
            decoding = "utf-8-replacement"
        document = lex(code)
        units = declarations(code, document)
        texts[fp], decls[fp] = code, units
        record = {"fp_sol": fp, "sha256": hashlib.sha256(content).hexdigest(),
                  "bytes": len(content), "decoding": decoding,
                  "has_null_byte": "\x00" in code, "declarations": "|".join(x["name"] for x in units),
                  "lex_errors": "|".join(document.errors),
                  "pragma": "|".join(re.findall(r"\bpragma\s+solidity\s+([^;]+);", document.mask)),
                  "is_empty": not document.clean.strip()}
        source_meta.append(record)
    sources = pd.DataFrame(source_meta)
    missing_files = rows[rows.fp_sol.ne("") & ~rows.fp_sol.isin(texts)].copy()
    print(f"Loaded {len(rows)} assessments, {len(sources)} source files", flush=True)
    groups, edges = source_groups(rows, texts, root)
    sources["group_id"] = sources.fp_sol.map(groups)
    bindings, entity_records = [], {}
    sources_by_fp = sources.set_index("fp_sol")
    for index, row in rows.iterrows():
        fp, raw_name = row.fp_sol, row.contractname
        reason, name = "", raw_name.strip().split(":")[-1]
        units = decls.get(fp, [])
        if not fp:
            reason = "no_source_reference"
        elif fp not in texts:
            reason = "missing_source_file"
        else:
            matches = [x for x in units if x["name"] == name] if name else []
            if not name and len(units) == 1:
                matches, name = units, units[0]["name"]
                reason = "inferred_single_declaration"
            if len(matches) != 1:
                reason = "ambiguous_or_missing_contract_name" if not name else "contract_name_not_unique_or_not_found"
            else:
                reason = reason or "exact_contract_name"
                entity_id = hashlib.sha256((fp + ":" + name).encode()).hexdigest()[:24]
                if entity_id not in entity_records:
                    document = lex(texts[fp])
                    selected = matches[0]
                    by_name = {x["name"]: x for x in units}
                    included, todo, external = {}, [selected], set()
                    while todo:
                        unit = todo.pop()
                        if unit["name"] in included:
                            continue
                        included[unit["name"]] = unit
                        for base in unit["bases"]:
                            if base in by_name:
                                todo.append(by_name[base])
                            else:
                                external.add(base)
                    # Original identifiers remain; metadata comments never enter the model.
                    chunks = [document.clean[u["start"]:u["end"]] for u in sorted(included.values(), key=lambda x: x["start"])]
                    code = "\n\n".join(chunks)
                    relative = f"data/processed/model_inputs/{entity_id}.sol"
                    (root / relative).write_text(code)
                    source_row = sources_by_fp.loc[fp]
                    entity_records[entity_id] = {
                        "entity_id": entity_id, "fp_sol": fp, "contract_name": name,
                        "kind": selected["kind"], "group_id": groups[fp], "model_input": relative,
                        "same_file_bases_n": len(included) - 1,
                        "external_bases": "|".join(sorted(external)),
                        "source_lex_errors": source_row.lex_errors,
                        "source_decoding": source_row.decoding,
                        "lex_errors": "|".join(lex(code).errors),
                        "is_empty": not code.strip(),
                        "pragma": source_row.pragma,
                    }
                bindings.append({"row": int(index), "entity_id": entity_id, "binding": reason})
                continue
        bindings.append({"row": int(index), "entity_id": "", "binding": reason})
    binding = pd.DataFrame(bindings)
    joined = rows.join(binding.set_index("row"))
    entities = pd.DataFrame(entity_records.values()).sort_values("entity_id")
    entities, groups, edges = refine_groups_for_model_inputs(entities, groups, edges, root)
    sources["group_id"] = sources.fp_sol.map(groups)
    provenance = joined[joined.entity_id.ne("")].assign(assessment_row=lambda p: p.index).groupby("entity_id").agg(
        datasets=("dataset", lambda x: "|".join(sorted(set(x)))),
        source_properties=("property", lambda x: "|".join(sorted(set(x)))),
        assessments_n=("id", "size"),
        assessment_rows=("assessment_row", lambda x: "|".join(map(str, x))),
    )
    entities = entities.join(provenance, on="entity_id")
    entities["has_solidifi_origin"] = entities.datasets.str.split("|").map(lambda x: "SolidiFI" in x)
    entities["model_eligible_preliminary"] = (
        entities.source_lex_errors.eq("") & entities.lex_errors.eq("") & ~entities.is_empty
        & entities.source_decoding.eq("utf-8") & ~entities.has_solidifi_origin
        & entities.kind.eq("contract")
    )
    bound = joined[joined.entity_id.ne("") & joined.swc.ne("") & joined.property_holds.isin(["t", "f"])].copy()
    bound["swc"] = bound.swc.astype(int)
    label_records = []
    for (entity_id, swc), part in bound.groupby(["entity_id", "swc"], sort=True):
        values = set(part.property_holds)
        conflict = len(values) != 1
        label_records.append({"entity_id": entity_id, "swc": int(swc),
                              "label": np.nan if conflict else int(next(iter(values)) == "t"),
                              "conflict": conflict, "assessment_n": len(part),
                              "datasets": "|".join(sorted(set(part.dataset))),
                              "properties": "|".join(sorted(set(part.property)))})
    labels = pd.DataFrame(label_records)
    represented = labels[labels.label.notna()].merge(entities[["entity_id", "model_input_hash", "contract_name", "pragma"]], on="entity_id")
    disagreement_groups = represented.groupby(["model_input_hash", "swc"]).label.nunique()
    disagreement_keys = disagreement_groups[disagreement_groups.gt(1)].reset_index()[["model_input_hash", "swc"]]
    representation_disagreements = represented.merge(disagreement_keys, on=["model_input_hash", "swc"])
    swcs = sorted(bound.swc.unique())
    targets = labels.pivot(index="entity_id", columns="swc", values="label").reindex(entities.entity_id)
    targets.columns = [f"swc_{x}" for x in targets.columns]
    entities = entities.join(targets, on="entity_id")
    conflicts = labels[labels.conflict].groupby("entity_id").swc.agg(
        lambda x: "|".join(map(str, sorted(x))))
    entities["conflicting_swcs"] = entities.entity_id.map(conflicts).fillna("")
    # Re-running preparation preserves the fixed experiment and notebook features.
    if previous is not None:
        if set(previous.index) != set(entities.entity_id):
            raise ValueError("Contract set changed. Review the existing partition before rebuilding.")
        current = entities.set_index("entity_id")
        for column in ("group_id", "model_input_hash", "canonical_model_input_hash", "model_eligible_preliminary"):
            if not current[column].eq(previous[column].reindex(current.index)).all():
                raise ValueError(f"Prepared input changed: {column}. Review the existing experiment.")
        for column in targets.columns:
            old_values = pd.to_numeric(previous[column].replace("", np.nan), errors="raise").reindex(current.index)
            if not np.allclose(current[column], old_values, equal_nan=True):
                raise ValueError(f"Labels changed: {column}. Review the existing experiment.")
        extra_columns = previous.columns.difference(entities.columns, sort=False)
        entities = entities.join(previous[extra_columns], on="entity_id")
    if "partition" not in entities:
        entities["partition"] = ""
    assert all(groups[row.a] == groups[row.b] for row in edges.itertuples(index=False))
    diagnostics = {
        "commit": COMMIT,
        "conflict_policy": "exclude_conflicting_entity_swc_label_only",
        "invalid_rows": raw_issues,
        "unbound_assessments": binding[binding.entity_id.eq("")][["row", "binding"]].to_dict(orient="records"),
        "representation_label_disagreements": representation_disagreements[["entity_id", "swc"]].to_dict(orient="records"),
        "clone_links_verified": True,
        "prepared_table": "data/processed/contracts.csv",
    }
    destination = processed / "contracts.csv"
    temporary = destination.with_suffix(".csv.tmp")
    entities.to_csv(temporary, index=False)
    temporary.replace(destination)
    save_json(processed / "preparation_audit.json", diagnostics)
    print(f"Prepared {len(entities)} contracts with SWC columns. Statistics are calculated in the notebook.")
    return entities



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=ROOT)
    args = parser.parse_args()
    audit(args.root)
