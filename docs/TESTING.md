# Build and test

From the repository root:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install lupa==2.8
.venv/bin/python tests/run.py
python3 tools/build.py
```

Tests run the production addon in isolated Lua 5.1 simulations. They cover quest facts, catalogue coverage, party messaging, stale sessions, UI controls, and loot recovery. Lupa is not included in the install ZIP.

The builder creates the versioned ZIP and SHA-256 checksum in `dist/`, using the TOC load order. The ZIP contains one `ZKIRPartyQuesting/` folder, the license, and user documentation.

## In-game checklist — not yet completed

Record the game build, addon version, quest/NPC IDs, party composition, steps, and actual result. Enable Lua errors with `/console scriptErrors 1`. Test 2–5-player parties outdoors and in dungeons.

- [ ] `/zkir`, preview, sound, size, docking, and close/reopen work. Normal quest/dialogue controls remain available.
- [ ] Supported acceptance, turn-in, and dialogue interactions warn before acting. Prerequisite objectives completed but not handed in remain distinct. Test A-Me #4245 and Celebras #7046.
- [ ] All-addon and mixed-addon groups show every member. Only one client announces; prefer the actual leader. Missing data stays Unknown. Leader confirmations cannot override verified blockers or disconnections.
- [ ] Unrelated quest updates preserve confirmations; relevant changes, leader changes, and retries invalidate them. Reloads and simultaneous detections do not duplicate announcements. Completed solo actions remain quiet after grouping.
- [ ] Changed dialogue choices open fresh checks. At later Pusillin stops, use `/zkir retry` if unchanged or unavailable option IDs prevent a fresh check. Messaging failure must never show false readiness or spam.
- [ ] Outdoor FFA defaults off. Verify friends, listed characters, mixtures, stranger joins, disconnections, restoration, manual pause, Unicode names, and reload/leadership recovery. Confirm the actual loot method and unchanged loot threshold.
- [ ] Dungeon Group Loot applies as leader even with FFA options off. Check manual changes, combat/looting restrictions, entering/leaving, and nonleader/raid exclusions.

Simulations cannot establish live API access, visual layout, chat delivery, encounter behavior, or quest credit. Record invitations, actual acceptance, and eventual credit separately from readiness.

Report bugs through [GitHub issues](https://github.com/Farwanda/ZKIR-party-questing/issues), with the details above and any Lua error; redact private player/account information.
