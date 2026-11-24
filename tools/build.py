#!/usr/bin/env python3
"""Build a deterministic, single-folder install ZIP without development dependencies."""
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED
import hashlib
import re

root = Path(__file__).resolve().parents[1]
addon = root / "ZKIRPartyQuesting"
toc = addon / "ZKIRPartyQuesting.toc"
files = [(toc, toc.name)]
for line in toc.read_text().splitlines():
    if line and not line.startswith("#"):
        assert "/" not in line and "\\" not in line and line.endswith(".lua")
        files.append((addon / line, line))
for name in ("README.md", "LICENSE", "THIRD_PARTY_NOTICES.md", "docs/MULTIPLAYER_CHECKLIST.md",
             "docs/PROTOCOL.md", "research/IMPLEMENTATION_REVIEW.md", "research/ESCORT_COVERAGE.md",
             "research/DUNGEON_AUDIT.md"):
    files.append((root / name, name))
version = next(line.removeprefix("## Version: ").strip() for line in toc.read_text().splitlines()
               if line.startswith("## Version: "))
assert re.fullmatch(r"\d+\.\d+(?:\.\d+)?", version), "TOC must contain a release version"
output = root / "dist" / f"ZKIRPartyQuesting-{version}.zip"
output.parent.mkdir(exist_ok=True)
with ZipFile(output, "w", compression=ZIP_DEFLATED, compresslevel=9) as archive:
    for source, name in sorted(files, key=lambda item: item[1]):
        entry = ZipInfo("ZKIRPartyQuesting/" + name, date_time=(2026, 11, 23, 0, 0, 0))
        entry.compress_type = ZIP_DEFLATED
        entry.external_attr = 0o100644 << 16
        archive.writestr(entry, source.read_bytes())
with ZipFile(output) as archive:
    assert archive.testzip() is None
    assert len(archive.namelist()) == len(files)
digest = hashlib.sha256(output.read_bytes()).hexdigest()
output.with_suffix(".zip.sha256").write_text(digest + "  " + output.name + "\n")
print(f"Built {output.name}: {len(files)} files, {output.stat().st_size} bytes; SHA-256 {digest}")
