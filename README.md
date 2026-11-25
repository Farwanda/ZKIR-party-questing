# ZKIR PARTY QUESTING

A small advisory addon for **WoW Forever 1.60.1, interface 16001**. It warns before 102 researched quest/NPC interactions, opens one party window automatically, exchanges preparation facts, and sends the warning and next-action message automatically. Normal quest, reward, and dialogue controls remain available.

**Install:** extract [ZKIRPartyQuesting-1.1.zip](https://github.com/Farwanda/ZKIR-party-questing/raw/refs/heads/main/dist/ZKIRPartyQuesting-1.1.zip) into your Forever client's `Interface/AddOns` directory. The resulting path must be `Interface/AddOns/ZKIRPartyQuesting/ZKIRPartyQuesting.toc`. Enable **ZKIR PARTY QUESTING**, then restart the client if installing while it is open. No libraries or other addons are required.

**Updating:** replace the existing `ZKIRPartyQuesting` folder, then restart WoW or `/reload`. **Use the current 1.1 package on every addon client**; early development builds may not recognize the expanded catalogue. This release adds optional Auto FFA and retains all 102 interactions. Older ZIPs are historical builds; release numbering was previously reset to 1.0. Existing preferences are preserved and development diagnostics are removed. No SavedVariables deletion is needed.

Disable other addons' automatic quest acceptance, turn-in, and dialogue selection for these interactions. A warning cannot stop another addon from acting during the same game event.

## Normal use

Type **`/zkir`** to open settings at any time. The window shows the loaded version and current status, including detected startup or messaging problems. **Preview warning** displays sample party rows locally, without sending chat or changing real readiness. **Reset window position** restores the settings, warning, and preview windows.

Settings are saved per character: **Warning sound** (on), **Show solo warnings** (on), and **Window size** (Small / Normal / Large; Normal by default), plus the two Auto FFA options below. Sound plays once for a new displayed attempt. Disabling solo warnings affects automatic solo presentation; party coordination remains automatic. Preview and reopening a warning are silent.

**Auto FFA:** both **With Battle.net friends** and **With these characters** start **off**. When you lead an ordinary 2–5-player party, every other member must be connected and match at least one enabled option. Use **Characters...** to save one `Name-Realm` per line; a name alone uses your current realm. Both options together allow a mix of friends and listed characters. Only the leader needs the addon for this feature. The settings window shows its current state.

After two seconds of stable evidence, the addon requests Free for All and checks the result. Missing friend/identity information cannot authorize FFA. Manual loot changes pause automation; change an Auto FFA checkbox to resume. When eligibility ends or you turn it off, the addon tries to restore the method it changed, while you still lead. Reloads or leadership changes interrupt that recovery: check loot manually, then toggle an option to resume. It never takes ownership of FFA that was already set. See [Auto FFA behavior and evidence](docs/AUTO_LOOT.md) for recovery limits and privacy details.

Open a supported quest or NPC conversation and **wait**. Every responding addon opens the window. All current party members appear, including nonresponders. Discovery takes about five seconds, followed by announcement acknowledgement; the local warning appears immediately.

Hover a row for its specific blocker or missing evidence.

- **Ready — automatic:** the researched preparation for the upcoming action was checked. Acceptance checks include prerequisite hand-ins, an absent/unrewarded target, required level/faction, log space, and conflicting branches where applicable. Nobody must accept an escort before its first acceptance. Mason's coordinated hand-in instead checks that each quest holder has finished the objectives. This does not check range, layers, NPC availability, combat preparation, or guarantee an invitation or credit.
- **Not Ready — automatic:** a known blocker or disconnection. Complete objectives on a prerequisite do **not** count as handing it in.
- **Waiting:** an addon response is still expected.
- **Unknown:** no response or insufficient evidence. The actual leader can use the row's Ready/Not ready controls. Confirmations are explicitly labelled **leader confirmed**. Stale addon facts and verified blockers cannot be overridden.

The leader's addon announces; otherwise the alphabetically first responding full player name announces under **its own name**. A leader without the addon can use `/p ZKIR TOKEN ready Name-Realm` or `notready` to resolve missing information. The initial fallback warning includes the token. `/p ZKIR status` requests current instructions; only the actual leader's commands count. Short names work only when unambiguous.

When everyone is ready, the UI says **You may proceed** and the elected sender announces the specific next action once. There is no announcement or proceed button. Solo play shows local warnings without PARTY traffic.

`/zkir show` reopens the current warning, including a hidden solo warning, or opens settings if no interaction is active. `/zkir retry` starts a **new attempt**, clearing confirmations; use it after coordinating a real retry, a later Pusillin conversation, a changed Rocknot hand-in plan, or restoring failed communication. The addon does not identify those later stages automatically, and retry cannot reset an NPC. `/zkir status` prints the current local status. No automatic quest sharing or acceptance is performed.

## Coverage and verification

Version 1.1 covers **77 acceptance warnings, 19 dialogue warnings, and 6 turn-in warnings**. It includes the 17 dungeon additions: Emi/Grubbis, Doom'rel, Windsor's prisoner releases, Pusillin, Knot, Rocknot, Mason in Alcaz, Bramblesnap in Blackmaw, and Grindle's Dalaran barriers. The [dungeon audit](research/DUNGEON_AUDIT.md) reviews **34 areas, including all nine new Forever dungeons**, and records each addition, source and remaining gap. The [earlier 85-rule catalogue](research/ESCORT_COVERAGE.md) lists the other interactions, including A-Me and all 74 previously researched supported entries.

**59 rules can establish preparation automatically; 43 retain missing details for leader assessment.** These include newer escorts with unverified sharing/access, class-event helper roles, repeatable defenses, and dungeon dialogue without quest-log evidence. Conflicting minimum levels for Willix (22/23) and Kernobee (20/24) leave the disputed ranges Unknown. Known blockers still win. Warnings appear when the relevant offer or conversation opens; ambiguous alternative offers wait for the selected quest's detail screen. The Attack! #434 warns at Tyrion's start conversation after acceptance, reflecting the researched Forever change.

This is a broad curated catalogue, **not a guarantee that every Forever escort or dungeon event is covered**. Cages, braziers, consoles, item use, combat/proximity triggers, some later escort stages, raid coordination, and insufficiently identified scripts remain gaps. For example, Alcaz's earlier Questioner kill-order hazard is not covered by Mason's hand-in warning. The addon cannot pause an NPC's schedule or prevent resets.

**Simulated verification:** Lua 5.1 tests pass for 28 Auto FFA scenarios (139 checks), 19 settings scenarios (192 checks), and all existing quest protocol, adapter, catalogue, dungeon and preparation checks. The supplied client log confirmed friend lookup and one FFA/restore probe; the production feature and UI have not been field-tested. See the [multiplayer field checks](docs/MULTIPLAYER_CHECKLIST.md), [Auto FFA evidence](docs/AUTO_LOOT.md), and [protocol limits](docs/PROTOCOL.md). The dungeon audit extends and corrects the earlier catalogue; other research files are historical material.

Run tests with Lua 5.1 via `python3 -m pip install lupa==2.8`, then `python3 tests/run.py`. Build the deterministic install ZIP with `python3 tools/build.py`.
