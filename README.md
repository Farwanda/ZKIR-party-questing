# ZKIR PARTY QUESTING

A small advisory addon for **WoW Forever 1.60.1, interface 16001**. It warns before 102 researched quest/NPC interactions, opens one party window automatically, exchanges preparation facts, and sends the warning and next-action message automatically. Normal quest, reward, and dialogue controls remain available.

**Install:** extract [ZKIRPartyQuesting-1.2.zip](https://github.com/Farwanda/ZKIR-party-questing/raw/refs/heads/main/dist/ZKIRPartyQuesting-1.2.zip) into your Forever client's `Interface/AddOns` directory. The resulting path must be `Interface/AddOns/ZKIRPartyQuesting/ZKIRPartyQuesting.toc`. Enable **ZKIR PARTY QUESTING**, then restart the client if installing while it is open. No libraries or other addons are required.

**Updating:** replace the existing `ZKIRPartyQuesting` folder, then restart WoW or `/reload`. **Use the current 1.2 package on every addon client.** This release adds the compact attached panel, shorter messages, and internal cleanup. All 102 interactions, readiness rules, and optional Auto FFA behavior are retained. Existing preferences are preserved. No SavedVariables deletion is needed. [Older packages](https://github.com/Farwanda/ZKIR-party-questing/tree/main/archive/releases) are archived separately; earlier development version numbers predate the reset to 1.0.

Disable other addons' automatic quest acceptance, turn-in, and dialogue selection for these interactions. A warning cannot stop another addon from acting during the same game event.

## Normal use

Type **`/zkir`** to open settings at any time. The window shows the loaded version and current status, including detected startup or messaging problems. **Preview warning** displays sample party rows locally, without sending chat or changing real readiness. **Reset window position** restores the settings, warning, and preview windows.

Settings are saved per character: **Warning sound** (on), **Show solo warnings** (on), and **Window size** (Small / Normal / Large; Normal by default), plus the two Auto FFA options below. Sound plays once for a new displayed attempt. Disabling solo warnings affects automatic solo presentation; party coordination remains automatic. Preview and reopening a warning are silent.

**Auto FFA:** both **With Battle.net friends** and **With these characters** start **off**. When you lead an ordinary 2–5-player party, every other member must be connected and match at least one enabled option. Use **Characters...** to save one `Name-Realm` per line; a name alone uses your current realm. Both options together allow a mix of friends and listed characters. Only the leader needs the addon for this feature. The settings window shows its current state.

After two seconds of stable evidence, the addon requests Free for All and checks the result. Missing friend/identity information cannot authorize FFA. Manual loot changes pause automation; change an Auto FFA checkbox to resume. When eligibility ends or you turn it off, the addon tries to restore the method it changed, while you still lead. Reloads or leadership changes interrupt that recovery: check loot manually, then toggle an option to resume. It never takes ownership of FFA that was already set. See [Auto FFA behavior and evidence](docs/AUTO_LOOT.md) for recovery limits and privacy details.

Open a supported quest or NPC conversation and **wait**. The 340-pixel panel attaches beside the matching native quest or gossip dialogue and sizes itself to the party. If that dialogue is closed, unrelated, or replaced by another addon, it uses a draggable floating position. Every responding client opens the panel automatically, including players not talking to the NPC. Closing the NPC dialogue does not cancel coordination. Discovery takes about five seconds, followed by announcement acknowledgement; the local warning appears immediately.

The main instruction is direct: **WAIT. DON'T ACCEPT NEXT QUEST YET. WAIT FOR OTHERS**. Blocked rows show the required action directly, such as **Turn in Legends of Maraudon.** Hover for the full player name and evidence; **Details** holds the shared explanation. Same-name players retain their realms. Reset window position restores the floating position or reattaches to the matching dialogue.

- **Ready — automatic:** the researched preparation for the upcoming action was checked. Acceptance checks include prerequisite hand-ins, an absent/unrewarded target, required level/faction, log space, and conflicting branches where applicable. Nobody must accept an escort before its first acceptance. Mason's coordinated hand-in instead checks that each quest holder has finished the objectives. This does not check range, layers, NPC availability, combat preparation, or guarantee an invitation or credit.
- **Not Ready — automatic:** a known blocker or disconnection. Complete objectives on a prerequisite do **not** count as handing it in.
- **Waiting:** an addon response is still expected.
- **Unknown:** no response or insufficient evidence. The actual leader opens **Check** on the row, then chooses **Ready** or **Not ready**. Manual evidence is labelled **· Leader**. Stale addon facts and verified blockers cannot be overridden.

The leader's addon announces; otherwise the alphabetically first responding full player name announces under **its own name**. A leader without the addon can use `/p ZKIR TOKEN ready Name-Realm` or `notready` to resolve missing information. The initial fallback warning includes the token. `/p ZKIR status` requests current instructions; only the actual leader's commands count. Short names work only when unambiguous.

When everyone is ready, the UI says **ALL READY** with the next action, such as **One player: accept. Others: accept if invited.** The elected sender announces it once. There is no announcement or proceed button. After an observed action the panel collapses to a short progress notice; an invitation still tells you to use the game's prompt. Solo play shows local warnings without PARTY traffic.

`/zkir show` reopens the current warning, including a hidden solo warning, or opens settings if no interaction is active. `/zkir retry` starts a **new attempt**, clearing confirmations; use it after coordinating a real retry, a later Pusillin conversation, a changed Rocknot hand-in plan, or restoring failed communication. The addon does not identify those later stages automatically, and retry cannot reset an NPC. `/zkir status` prints the current local status. No automatic quest sharing or acceptance is performed.

## Coverage and verification

Version 1.2 covers **77 acceptance warnings, 19 dialogue warnings, and 6 turn-in warnings**. It includes the 17 dungeon additions: Emi/Grubbis, Doom'rel, Windsor's prisoner releases, Pusillin, Knot, Rocknot, Mason in Alcaz, Bramblesnap in Blackmaw, and Grindle's Dalaran barriers. The [dungeon audit](https://github.com/Farwanda/ZKIR-party-questing/blob/main/research/DUNGEON_AUDIT.md) reviews **34 areas, including all nine new Forever dungeons**, and records each addition, source and remaining gap. The [earlier 85-rule catalogue](https://github.com/Farwanda/ZKIR-party-questing/blob/main/research/ESCORT_COVERAGE.md) lists the other interactions, including A-Me and all 74 previously researched supported entries.

**59 rules can establish preparation automatically; 43 retain missing details for leader assessment.** These include newer escorts with unverified sharing/access, class-event helper roles, repeatable defenses, and dungeon dialogue without quest-log evidence. Conflicting minimum levels for Willix (22/23) and Kernobee (20/24) leave the disputed ranges Unknown. Known blockers still win. Warnings appear when the relevant offer or conversation opens; ambiguous alternative offers wait for the selected quest's detail screen. The Attack! #434 warns at Tyrion's start conversation after acceptance, reflecting the researched Forever change.

This is a broad curated catalogue, **not a guarantee that every Forever escort or dungeon event is covered**. Cages, braziers, consoles, item use, combat/proximity triggers, some later escort stages, raid coordination, and insufficiently identified scripts remain gaps. For example, Alcaz's earlier Questioner kill-order hazard is not covered by Mason's hand-in warning. The addon cannot pause an NPC's schedule or prevent resets.

**Simulated verification:** Lua 5.1 tests cover dialogue attachment/transitions, remote fallback, stale controls, short messages across all 102 rules, isolated preview, settings, and all existing quest/FFA behavior. The supplied client log confirmed friend lookup and one FFA/restore probe; the production feature and new UI have not been field-tested. Font wrapping, screen clamping, and custom quest UI compatibility require the [multiplayer field checks](docs/MULTIPLAYER_CHECKLIST.md). See [Auto FFA evidence](docs/AUTO_LOOT.md) and [protocol limits](docs/PROTOCOL.md). Research remains available in the repository and is omitted from the smaller install ZIP.

Run tests with Lua 5.1 via `python3 -m pip install lupa==2.8`, then `python3 tests/run.py`. Build the deterministic install ZIP with `python3 tools/build.py`.
