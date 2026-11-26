#!/usr/bin/env python3
"""Run the actual addon under Lua 5.1, with deterministic game/network stubs."""
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
print("All simulated tests passed (Lua 5.1). No live game verification.")
