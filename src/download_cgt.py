"""Fetch an immutable CGT snapshot. Never executes code from the dataset."""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import shutil
import subprocess
import urllib.request
import zipfile
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath

COMMIT = "f8cd72cf7fbbfebc809c454667eee271706a4b2b"
ROOT = Path(__file__).resolve().parents[1]
URL = f"https://codeload.github.com/gsalzer/cgt/zip/{COMMIT}"
FILES = {
    "README.md", "LICENSE.txt", "consolidated.csv",
    "construction/README.md", "construction/sql/02_mapping.csv",
    "construction/sql/03_ignore.sql", "construction/sql/08_disagreement_errors.csv",
    "construction/sql/09_checked.csv", "construction/sql/10_consolidated.sql",
    "construction/sql/11_analysis.txt",
}


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def download(root: Path = ROOT, method: str = "git") -> dict:
    destination = root / "data/raw/cgt"
    manifest_path = root / "data/raw/cgt_manifest.json"
    if manifest_path.exists():
        manifest = json.loads(manifest_path.read_text())
        if manifest["commit"] != COMMIT:
            raise ValueError("Existing snapshot is not the pinned CGT commit")
        for item in manifest["files"]:
            path = destination / item["path"]
            if not path.is_file() or sha256(path.read_bytes()) != item["sha256"]:
                raise ValueError(f"Snapshot integrity check failed: {item['path']}")
        return manifest
    destination.mkdir(parents=True, exist_ok=True)
    records = []
    transport = {}
    if method == "git":
        # Do not transfer construction/originalSets or bytecode/runtime artifacts.
        checkout = root / "tmp/cgt_checkout"
        checkout.mkdir(parents=True, exist_ok=True)
        git = shutil.which("git")
        if not git:
            raise RuntimeError("Git is required for sparse download; use --method archive otherwise")
        def run(*args, **kwargs):
            print("git " + " ".join(args[:4]), flush=True)
            return subprocess.run([git, "-C", str(checkout), *args], check=True, text=True, **kwargs)
        if not (checkout / ".git").exists():
            run("init", "--quiet")
            run("remote", "add", "origin", "https://github.com/gsalzer/cgt.git")
        run("config", "remote.origin.promisor", "true")
        run("config", "remote.origin.partialclonefilter", "blob:none")
        run("sparse-checkout", "init", "--no-cone")
        patterns = "/source/\n" + "\n".join("/" + name for name in sorted(FILES)) + "\n"
        run("sparse-checkout", "set", "--no-cone", "--stdin", input=patterns)
        run("fetch", "--depth=1", "--filter=blob:none", "origin", COMMIT)
        run("checkout", "--detach", COMMIT)
        actual = run("rev-parse", "HEAD", capture_output=True).stdout.strip()
        if actual != COMMIT:
            raise ValueError("Git checkout commit mismatch")
        for path in sorted(checkout.rglob("*")):
            if not path.is_file() or ".git" in path.relative_to(checkout).parts:
                continue
            name = path.relative_to(checkout).as_posix()
            if name not in FILES and not (name.startswith("source/") and name.endswith(".sol")):
                continue
            content = path.read_bytes()
            target = destination / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)
            records.append({"path": name, "bytes": len(content), "sha256": sha256(content)})
        transport = {"transport": "git sparse checkout with blob:none", "verified_head": actual}
    else:
        request = urllib.request.Request(URL, headers={"User-Agent": "YearProject-EDA/1.0"})
        chunks, received = [], 0
        with urllib.request.urlopen(request, timeout=90) as response:
            while chunk := response.read(1024 * 1024):
                chunks.append(chunk)
                received += len(chunk)
                print(f"Archive received: {received / 1024 / 1024:.1f} MiB", flush=True)
                if received > 256 * 1024 * 1024:
                    raise ValueError("Archive exceeds the 256 MiB size limit")
        archive = b"".join(chunks)
        with zipfile.ZipFile(io.BytesIO(archive)) as zipped:
            for member in sorted(zipped.infolist(), key=lambda x: x.filename):
                if member.is_dir():
                    continue
                components = PurePosixPath(member.filename).parts
                relative = PurePosixPath(*components[1:])
                if ".." in relative.parts or relative.is_absolute():
                    raise ValueError("Unsafe archive member")
                name = relative.as_posix()
                if name not in FILES and not (name.startswith("source/") and name.endswith(".sol")):
                    continue
                content = zipped.read(member)
                target = destination / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(content)
                records.append({"path": name, "bytes": len(content), "sha256": sha256(content)})
        transport = {"transport": "archive", "archive_url": URL,
                     "archive_bytes": len(archive), "archive_sha256": sha256(archive)}
    manifest = {
        "repository": "https://github.com/gsalzer/cgt",
        "commit": COMMIT, **transport,
        "retrieved_utc": datetime.now(timezone.utc).isoformat(),
        "files": records,
        "license_note": "Dataset artifacts retain their original licenses; repository code is MIT.",
    }
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    return manifest


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--method", choices=["git", "archive"], default="git")
    args = parser.parse_args()
    result = download(args.root, args.method)
    print(json.dumps({k: v for k, v in result.items() if k != "files"}, indent=2))
    print(f"Verified files: {len(result['files'])}")

