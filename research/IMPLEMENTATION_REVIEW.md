# Historical development build 1.0.1 catalogue and post-implementation audit

**Superseded for current coverage by the [development escort audit](ESCORT_COVERAGE.md) and [current 1.0 dungeon audit](DUNGEON_AUDIT.md).** The twelve-rule inventory and exclusions below describe development build 1.0.1. The current 1.0 release ships 102 interactions; this report is retained for the original API review and A-Me regression history.

Initially reviewed **23 November 2026**; A-Me 01 fix and sources rechecked **24 November 2026**. This report describes the twelve rules shipped in 1.0.1. The pre-existing 102-record archive is research material, not a runtime inventory. No live client was available to the developer; source review and emulator history are not live Forever script verification.

## Included IDs and evidence

The [QuestieDB Forever records](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua) were downloaded again and programmatically compared with the shipped prerequisite IDs, levels, starting NPCs, and party-accept flags. All ten acceptance records carry flag 2. The [flag definitions](https://github.com/Questie/QuestieDB/blob/master/src/corrections/enum/quests.lua) distinguish this from ordinary sharing (8). [Questie's current automatic-interaction exclusions](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua) independently include all ten. Exclusion lists corroborate hazards; they do not prove server timing.

| Upcoming action | Quest | NPC | Required earlier hand-in | Preparation policy |
| --- | ---: | ---: | ---: | --- |
| Defias acceptance | 155 | 467 | 142 | Automatic |
| OOX Tanaris acceptance | 648 | 7784 | 351 | Automatic |
| Remtravel acceptance | 731 | 2917 | 729 | Automatic |
| OOX Hinterlands acceptance | 836 | 7806 | 485 | Automatic |
| Therylune acceptance | 945 | 3584 | None enforced | Automatic |
| OOX Feralas acceptance | 2767 | 7807 | 2766 | Automatic |
| A-Me 01 acceptance | 4245 | 9623 | 4244 | Automatic |
| Kerlonian acceptance | 5321 | 11218 | None enforced | Automatic |
| Ruul acceptance | 6482 | 12818 | None enforced | Automatic |
| Celebras acceptance | 7046 | 13716 | 7044 | Automatic |
| Robot key dialogue | 2078 | 6669 | 2098 | Known quest blockers; missing details require leader |
| Nagmara turn-in | 4201 | 9500 | None enforced | Missing participation details require leader |

Automatic means checking the curated preparation conditions, not full server eligibility. Required levels and faction restrictions come from the same records. Absence of a documented prerequisite is not generalized into an unrestricted-eligibility rule. A target already active is Unknown for a fresh acceptance, rather than assumed safe to join; completed/rewarded and failed states have distinct handling.

## What the second pass found

**A-Me 01 (1.0.1 correction, 24 November):** a user reported no warning at the Un'Goro gorilla escort. #4245 was present in the research archive but omitted from 1.0.0's runtime catalogue. Fresh Forever records confirm #4243 (find), #4244 (Mithril Casing repair), and #4245 (escort) are separate quests with the same title. #4245 starts at NPC #9623, requires level 48 and hand-in #4244, has no race restriction, and carries PARTY_ACCEPT=2. Questie's auto-accept exclusions include #4245. The legacy corrections link #4244 to #4245 and identify escort completion near Karna; current generated/authored Forever corrections contain no entries for these three IDs. The [quest text and inherited reports](https://www.wowhead.com/forever/quest=4245/chasing-a-me-01) also distinguish preparation from the escort. The rule warns at the escort offer, treats completed-but-held repair as blocked, and leaves unavailable history Unknown. It does not require retaining a casing after hand-in or accepting the escort before readiness. Regression tests reproduce the former missing warning and exercise quest facts and party synchronization. Current server start timing, invitations, and credit remain field checks.

**Celebras:** the retained archive called its group offer unknown, but the rechecked raw record has PARTY_ACCEPT=2 and prerequisite #7044. This release uses conditional “join when offered” guidance and observes the actual invitation event; it does not promise delivery. The [quest's player reports](https://www.wowhead.com/forever/quest=7046/the-scepter-of-celebras) and [legacy corrections](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/legacy/classicQuestFixes.lua) also identify a later ritual/book interaction (object #178965). Acceptance coordination does not automate or certify that later stage. Old emulator bug reports are not treated as current Forever defects.

**Kerlonian:** the [authored Forever corrections](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua) clear the inherited objectives and change #5321's escort target to his bag on the road south in Darkshore. The initial draft repeated the historical Horn of Awakening advice. The final warning instead tells players to gather and check supplies; the current bag/route and horn behavior are explicit field checks. No horn-based eligibility requirement was invented.

**OOX and Remtravel:** the audit retained the correct rescue/report pairs. Feralas uses #2766 → #2767, not a later-expansion replacement or a guessed #2541. Remtravel uses #729 → #731, despite the shared name. The [Itinerary author's changelog](https://www.curseforge.com/wow/addons/itinerary/files/9728482) specifically describes waiting for prerequisite hand-ins before these acceptance-triggered escorts; it also corroborates the Threshwackonator conversation as an escort start. No proprietary implementation was inspected or copied.

**Gyromast:** #6667 gives the quest, but robot #6669 is the dialogue trigger. The warning appears at conversation open because a current numeric option ID was not established. Active #2078 alone does not prove the key and robot are usable, so those details remain Unknown. The post-selection hook only observes and retires preparation; it does not choose, replace, or block any option.

**The Love Potion:** [quest-specific firsthand reports](https://www.wowhead.com/forever/quest=4201/the-love-potion) describe departure after completion and a separate repeat-use gossip interaction on later visits. These are inherited reports, not newly verified Forever playtests. The runtime warns at progress/reward screens, labels the consequence “Reported behavior,” and does not force every witness to hold a turn-in quest. Exact current hand-in timing and the repeat-use dialogue remain unverified/unimplemented.

The [generated Forever delta](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua) contained no direct records for these twelve IDs; authored and legacy corrections were also inspected. The [official November hotfix history](https://news.blizzard.com/en-us/article/24315281/wow-forever-hotfixes-november-20-2026) includes other escort fixes, including Dunston and Going Home. Those are not evidence that all escorts became safe or that old bugs still persist. This focused release does not add those new quest chains, Windsor, Naralex, Zul'Farrak gossip, gameobject starts, or later escort pauses without an action-specific rule and tests.

## API audit and limits

The [Forever TOC in Questie](https://github.com/Questie/Questie/blob/master/Questie_Forever.toc) supports interface 16001. The [Forever API source mirror](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated) was checked for quest history, current log state/capacity, message enums, and event payloads. The implementation uses current-character completion history, never account completion or disappearance as proof of hand-in; the second quest-count return excludes headers. It handles enum zero as success, explicit failure/lockdown, secret values, unavailable APIs, and Forever's first-argument `QUEST_ACCEPTED` and third-argument `QUEST_ACCEPT_CONFIRM` quest IDs.

Readiness does not infer range, layers, script phase, item usage, invitations, or eventual credit. Tests mock APIs and UI objects; actual screen rendering, protected-call behavior and multiplayer delivery are pending the [field checklist](../docs/MULTIPLAYER_CHECKLIST.md).

Quest-source snapshots were rechecked on 24 November; the chat enum snapshot is from 23 November. SHA-256 values (upstream contents are not bundled):

| Source | SHA-256 |
| --- | --- |
| Forever raw quest DB | `621d4a1670232c047e7d171d8f1fdbd31581458935ee59dd70836016838dc942` |
| Auto exclusions | `b1e7ee499cd4b9a8229b0a7f7b2ee89cc68ac57a40f885b18ff489865557f0a8` |
| Generated Forever base | `197dff16946293da0cd23722578cb383a498c6e8d046fc49a96a3777883a66c2` |
| Authored Forever fixes | `03c9fa06e1590b18cd18d2961f967ea2e0f562c9668cef22180410af07357ed0` |
| Legacy corrections | `76cd6a05f035826cabc6180a0ff2a1a37c5e7946c891eb0a06412fab5a4caf2e` |
| Chat enum definitions | `054dbce92640323faefa4f187526a9ce1b62f3e4a4ec7b3e2615e947a231f69e` |
