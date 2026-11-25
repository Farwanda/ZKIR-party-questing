#!/usr/bin/env python3
"""Run the actual addon under Lua 5.1, with deterministic game/network stubs."""
import json
import os
from pathlib import Path
import sys

try:
    from lupa.lua51 import LuaRuntime
except ImportError:
    sys.exit("Install test dependency: python3 -m pip install lupa==2.8")

root = Path(__file__).resolve().parents[1]
os.chdir(root)
for spec in sorted((root / "tests").glob("*_spec.lua")):
    runtime = LuaRuntime(unpack_returned_tuples=True)
    runtime.execute(spec.read_text(), name=str(spec))
runtime = LuaRuntime(unpack_returned_tuples=True)
runtime.execute('NS = {}; assert(loadfile("ZKIRPartyQuesting/Messages.lua"))("ZKIR", NS); assert(loadfile("ZKIRPartyQuesting/Rules.lua"))("ZKIR", NS)')
rules = runtime.globals().NS.Rules
reviewed = 0
for record in json.loads((root / "research/coverage.json").read_text())["records"]:
    if record["support"] not in ("automatic", "warning"):
        continue
    quest = record["questID"]
    kind = "g" if quest == 434 or record["trigger"] == "dialogue" else record["trigger"][0]
    assert rules[f"{kind}{quest}"] is not None, f"Reviewed quest {quest} missing from shipped rules"
    reviewed += 1
print(f"Archive coverage gate passed: all {reviewed} previously researched interactions are represented.")
print("All simulated tests passed (Lua 5.1). No live game verification.")
