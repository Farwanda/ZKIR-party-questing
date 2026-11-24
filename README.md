# ZKIR PARTY QUESTING

A small advisory addon for **WoW Forever 1.60.1, interface 16001**. It warns before 102 researched quest/NPC interactions, opens one party window automatically, exchanges preparation facts, and sends the warning and next-action message automatically. Normal quest, reward, and dialogue controls remain available.

**Install:** extract [ZKIRPartyQuesting-1.0.zip](https://github.com/Farwanda/ZKIR-party-questing/raw/refs/heads/main/dist/ZKIRPartyQuesting-1.0.zip) into your Forever client's `Interface/AddOns` directory. The resulting path must be `Interface/AddOns/ZKIRPartyQuesting/ZKIRPartyQuesting.toc`. Enable **ZKIR PARTY QUESTING**, then restart the client if installing while it is open. No libraries or other addons are required.

**Updating:** replace the existing `ZKIRPartyQuesting` folder, then restart WoW or `/reload`. **Use the current 1.0 package on every addon client**; early development builds may not recognize the expanded catalogue. Release numbering was reset from development version 1.2.0 to **1.0**, retaining all 102 interactions. Previous ZIPs are historical development builds. No SavedVariables deletion is needed.

Disable other addons' automatic quest acceptance, turn-in, and dialogue selection for these interactions. A warning cannot stop another addon from acting during the same game event.

## Normal use

Open a supported quest or NPC conversation and **wait**. Every responding addon opens the window. All current party members appear, including nonresponders. Discovery takes about five seconds, followed by announcement acknowledgement; the local warning appears immediately.

Hover a row for its specific blocker or missing evidence.

- **Ready — automatic:** the researched preparation for the upcoming action was checked. Acceptance checks include prerequisite hand-ins, an absent/unrewarded target, required level/faction, log space, and conflicting branches where applicable. Nobody must accept an escort before its first acceptance. Mason's coordinated hand-in instead checks that each quest holder has finished the objectives. This does not check range, layers, NPC availability, combat preparation, or guarantee an invitation or credit.
- **Not Ready — automatic:** a known blocker or disconnection. Complete objectives on a prerequisite do **not** count as handing it in.
- **Waiting:** an addon response is still expected.
- **Unknown:** no response or insufficient evidence. The actual leader can use the row's Ready/Not ready controls. Confirmations are explicitly labelled **leader confirmed**. Stale addon facts and verified blockers cannot be overridden.

The leader's addon announces; otherwise the alphabetically first responding full player name announces under **its own name**. A leader without the addon can use `/p ZKIR TOKEN ready Name-Realm` or `notready` to resolve missing information. The initial fallback warning includes the token. `/p ZKIR status` requests current instructions; only the actual leader's commands count. Short names work only when unambiguous.

When everyone is ready, the UI says **You may proceed** and the elected sender announces the specific next action once. There is no announcement or proceed button. Solo play shows local warnings without PARTY traffic.

`/zkir` reopens the window. `/zkir retry` starts a **new attempt**, clearing confirmations; use it after coordinating a real retry, a later Pusillin conversation, a changed Rocknot hand-in plan, or restoring failed communication. The addon does not identify those later stages automatically, and retry cannot reset an NPC. `/zkir status` displays local status. No automatic quest sharing or acceptance is performed.

## Coverage and verification

Version 1.0 covers **77 acceptance warnings, 19 dialogue warnings, and 6 turn-in warnings**. It includes the 17 dungeon additions: Emi/Grubbis, Doom'rel, Windsor's prisoner releases, Pusillin, Knot, Rocknot, Mason in Alcaz, Bramblesnap in Blackmaw, and Grindle's Dalaran barriers. The [dungeon audit](research/DUNGEON_AUDIT.md) reviews **34 areas, including all nine new Forever dungeons**, and records each addition, source and remaining gap. The [earlier 85-rule catalogue](research/ESCORT_COVERAGE.md) lists the other interactions, including A-Me and all 74 previously researched supported entries.

**59 rules can establish preparation automatically; 43 retain missing details for leader assessment.** These include newer escorts with unverified sharing/access, class-event helper roles, repeatable defenses, and dungeon dialogue without quest-log evidence. Conflicting minimum levels for Willix (22/23) and Kernobee (20/24) leave the disputed ranges Unknown. Known blockers still win. Warnings appear when the relevant offer or conversation opens; ambiguous alternative offers wait for the selected quest's detail screen. The Attack! #434 warns at Tyrion's start conversation after acceptance, reflecting the researched Forever change.

This is a broad curated catalogue, **not a guarantee that every Forever escort or dungeon event is covered**. Cages, braziers, consoles, item use, combat/proximity triggers, some later escort stages, raid coordination, and insufficiently identified scripts remain gaps. For example, Alcaz's earlier Questioner kill-order hazard is not covered by Mason's hand-in warning. The addon cannot pause an NPC's schedule or prevent resets.

**Simulated verification only:** 26 protocol scenario groups (including all 102 rules in mixed parties), 22 mocked API/UI groups, 217 catalogue preparation/message checks, 163 dungeon checks, and 20 preparation cases passed using Lua 5.1. No live client was available. See the [multiplayer field checks](docs/MULTIPLAYER_CHECKLIST.md) and [protocol limits](docs/PROTOCOL.md). The dungeon audit extends and corrects the earlier catalogue; other research files are historical material.

Run tests with Lua 5.1 via `python3 -m pip install lupa==2.8`, then `python3 tests/run.py`. Build the deterministic install ZIP with `python3 tools/build.py`.
