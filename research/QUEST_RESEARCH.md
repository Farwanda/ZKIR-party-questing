# Quest research — 23 November 2026

This retained research identifies **74 quest/event records: 8 with proposed automatic preparation checks and 66 with warning evidence and unresolved readiness conditions**. The manifest contains **102 records**, including **16 unresolved candidates and 12 exclusions**. The 74 records cover 72 acceptance triggers, one dialogue trigger and one turn-in trigger. They use real quest IDs; no synthetic quest or gossip-option IDs were assigned.

The implementation was removed on 23 November 2026. This report preserves the prior investigation, including its proposed checks and references to prototype behavior; those are not requirements for the next design. In particular, requiring everyone to keep the same NPC offer open was a discarded implementation choice, not an established universal game requirement. See the [data reuse notes](../README.md#how-to-reuse-the-data).

This was a bounded source and database investigation, not an exhaustive audit of Forever's server scripts. No live client or multiplayer accounts were available. “Verified” in the manifest means the cited material was reviewed on the stated date; it does not mean the behavior was reproduced in game. The complete per-record evidence, conditions, identifiers and limitations are in [CATALOGUE.md](CATALOGUE.md) and [coverage.json](coverage.json).

## Method and evidence boundaries

The pass started with the requested quest chains and inspected Questie's full automatic-interaction exclusion list, current releases, its Forever compatibility notes, and the linked QuestieDB. The database's legacy Forever rows, generated Forever base and authored corrections were compared. Objectives establish whether a quest involves an escort, defense or scripted sequence; an exclusion establishes that an author considers automatic interaction undesirable. Neither a blacklist nor a PARTY_ACCEPT flag alone establishes the precise server trigger.

The catalogue preserves four assessment levels. **Automatic** identifies records for which the previous design proposed preparation checks using a current exact offer, prerequisite rewards, a free slot and the same observed NPC instance. It is not proof of eligibility or live-tested support. **Warning** means the interaction hazard has supporting evidence but some readiness conditions remain unresolved. **Candidate** means the trigger, current applicability or eligibility evidence is incomplete. **Excluded** means the lead is a different chain stage, expansion version or a non-event automation exception.

Current metadata was cross-checked against Forever databases and selected quest-specific reports. Old comments retained on a `/forever/` page were treated as inherited evidence, not current playtest reports. The weakest shipped rule, The Love Potion, explicitly says “Reported behavior” and cannot become automatically ready. Conflicting prerequisite claims for The Attack! are recorded without inventing an alternative path or enforcing an uncertain blocker.

The [source snapshot index](source-snapshots.json) records SHA-256 hashes of inspected source files. Source URLs containing `master`, `main` or `forever` can change after this review. No upstream implementation or complete database is bundled; see [rights and attribution](../THIRD_PARTY_NOTICES.md).

## Proposed preparation checks from the previous assessment

| Quest ID | Quest / event | Required previous hand-in | Starting NPC |
| --- | --- | --- | --- |
| 155 | The Defias Brotherhood — Defias Traitor | 142 | 467 |
| 648 | Rescue OOX-17/TN! | 351 | 7784 |
| 731 | The Absent Minded Prospector — escort step | 729 | 2917 |
| 836 | Rescue OOX-09/HL! | 485 | 7806 |
| 945 | Therylune's Escape | No path enforced; current exact offer required | 3584 |
| 2767 | Rescue OOX-22/FE! | 2766 | 7807 |
| 5321 | The Sleeper Has Awakened | No path enforced; current exact offer required | 11218 |
| 6482 | Freedom to Ruul | No path enforced; current exact offer required | 12818 |

The discarded evaluator required fresh evidence of the exact quest offer at the same nonsecret NPC GUID, the relevant prerequisite rewards, an absent new quest and room to accept it. This was a conservative design choice. The reusable distinction is that a completed-but-unrewarded prerequisite is not handed in, and an acceptance-triggered escort must be coordinated before everyone accepts it. The game may still refuse or fail to deliver an invitation. The `groupOfferVerified` field records the researched invitation mechanism, not guaranteed delivery or measured range.

QuestieDB's [flag definitions](https://github.com/Questie/QuestieDB/blob/master/src/corrections/enum/quests.lua) distinguish PARTY_ACCEPT (2) from SHARABLE (8). Current [group-start reports](https://www.reddit.com/r/wowforever/comments/1xz8td0/escort_quests_should_only_start_when_manually/) describe the prerequisite/first-acceptance trap. The addon observes `QUEST_ACCEPT_CONFIRM` after the first start and then checks actual acceptance; ordinary sharing is not treated as proof that a running event can be joined.

These are start-readiness checks, not full escort-success checks. For example, Kerlonian's later sleep requires the Horn of Awakening; the warning mentions it, but the addon does not operate the horn or validate every later NPC state. Health, combat preparation, path clearance, world layers and server script state remain player responsibilities.

## Requested leads and important distinctions

- **OOX rescues:** #648, #836 and #2767 are the rescue stages. #351, #485 and #2766 are the beacon/report prerequisites. The later-expansion #25476 is not substituted for Forever #2767. A beacon objective completed in the log is not the hand-in needed before starting the rescue.
- **The Absent Minded Prospector:** #729 is the report-to step; #731 starts the escort. The addon does not warn on ordinary #729 acceptance. Later identically named chain steps are not conflated with #731.
- **Jail Break! #4322:** prerequisite #4282, Marshal Windsor #9023, Blackrock Depths. The initial acceptance warning is supported; later pause/dialogue stages need manual coordination and are not separate automatic rules. The addon cannot reset Windsor or promise a recoverable instance.
- **The Missing Diplomat:** #1249 follows #1248 and begins the Tapoke Jahn confrontation from Mikhail #4963 in Wetlands. #1324 follows #1266 and concerns Private Hendel #4966 in Dustwallow. Names alone would conflate these events. Questie's [specific #1249 fix](https://github.com/Questie/Questie/commit/99bef7a7b721aefb4ba070029ef91d62e9108d61) corroborates the automatic-accept hazard.
- **Dunston Checks Out #94927:** Riverglades, NPC #259057, prerequisite #96126 from authored Forever corrections. It remains a warning/manual rule because invitation and all eligibility conditions were not established. The November 20 running-speed fix is not evidence that starting early became safe.
- **Lost in the Shadows #99123:** Durotar, NPC #275811. It is distinct from **Escaping the Shadows #96811**. Missing prerequisite metadata is not treated as proof of unrestricted eligibility; both remain warning/manual rules.
- **Gyromast's Revenge #2078:** #2098 must be handed in, then #2078 accepted before the key dialogue with Threshwackonator #6669. Gelkak #6667 is the quest giver, not the robot trigger. The warning describes following and later hostility. No exact gossip-option ID was established, so it appears at the robot conversation and the leader marks the observed start. [Itinerary's changelog](https://www.curseforge.com/wow/addons/itinerary/files/9728482) independently identifies this dialogue hazard.
- **The Love Potion #4201:** the pre-turn-in warning appears at `QUEST_PROGRESS` and `QUEST_COMPLETE`, before reward selection. Historical reports describe Nagmara and Rocknot leaving after completion; current quest metadata retains the quest. Exact current timing and other players' hand-in window need field verification. Later repeat visits can involve dialogue after a prior completion; that separate repeat-use interaction is not implemented. [Quest-specific source](https://www.wowhead.com/forever/quest=4201/the-love-potion).

The wider supported set includes Willix in Razorfen Kraul, Belnistrasz in Razorfen Downs, Kernobee in Gnomeregan, Gor'shak and Windsor in Blackrock Depths, Celebras in Maraudon, caravan events, defense encounters and escorts across both continents and factions. Fourteen supported records are new Forever IDs above 80000. Their class/race restrictions and uncertain metadata are recorded in the catalogue. Examples include the Undead Paladin Windshaper chain and the Orc/Undead Seeking Refuge chain.

## Persistent hazards, bugs and fixed issues

Persistent hazards include an NPC leaving its offer location, an encounter beginning before prerequisite hand-ins, and a participant still needing to accept the relevant quest before a dialogue action. Advisory warnings address those decisions. Failure caused by server state is different: the addon does not claim to repair scripts or restore credit.

The [official November hotfix history](https://news.blizzard.com/en-us/article/24315281/wow-forever-hotfixes-november-20-2026) documents Dunston's running behavior fixed November 20, Rokren's speed reduced for Going Home on November 17, a Freedom for All Creatures cage-reset fix, a Return to Port item-removal fix and a No Soldier Left Behind party-credit correction. Fixed bugs are not represented as currently active faults. Dunston and Going Home still have normal coordination warnings.

Recent [world-refresh reports](https://www.reddit.com/r/wowforever/comments/1y1q8dx/world_refresh_needs_some_tweaks_for_escort_quests/) describe NPC loss or disrupted escorts. These are anecdotal reports, not verified eligibility rules. A [Forever escort discussion](https://us.forums.blizzard.com/en/wow/t/escort-quests/2356665) also describes the prerequisite-to-escort transition around Lumina. These sources motivate conservative checks but do not establish exact range thresholds, respawn times or recovery guarantees.

## Other addon research

| Source | Finding and effect on this MVP |
| --- | --- |
| [Questie releases](https://github.com/Questie/Questie/releases), 12.12.0 / QuestieDB 1.1.4 | Current Forever support and exclusions were inspected. The exclusion list includes non-escorts, item costs, travel and later-expansion entries. It is a candidate inventory, not a warning database. |
| [Questie exclusion implementation](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua) | Real escort/defense entries were cross-checked with objectives. Ordinary profession/material exclusions were rejected. Exact quest IDs avoid chain-name collisions. |
| [Itinerary](https://www.curseforge.com/wow/addons/itinerary), 2.9.3 | Public changelog reviewed for escort group waiting, dialogue exceptions and secret GUID compatibility. Proprietary code was not copied or represented as inspected. Its settings cannot guarantee ZKIR's readiness. |
| [QuestShare Forever](https://www.curseforge.com/wow/addons/questshare-forever), 1.2.3 | Public documentation describes accepting shared/escort invitations, not NPC offers. `/qs accept` controls that automation. No integration is required. |
| [Everything Quests source](https://github.com/wheelbarrel00/EverythingQuests/blob/main/Modules/QuestAuto.lua), 2.18.0 | Actual source handlers for quest detail, progress, reward and group confirmation were inspected. It can answer an escort invitation and hide the popup. Defaults keep automation off. Its changelog acknowledges incomplete exclusion coverage for new Forever escorts. |
| [Everything Quests defaults](https://github.com/wheelbarrel00/EverythingQuests/blob/main/Core/DB.lua) and [changelog](https://github.com/wheelbarrel00/EverythingQuests/blob/main/Core/Changelog.lua) | Party-accept metadata also includes ordinary class/holiday/battleground quests; flag-only automatic warnings would be noisy. Its group-quest option is separate from NPC auto-accept. |

Any addon accepting, turning in or selecting dialogue during the same game event can act before a person reads a warning. This MVP deliberately does not intercept controls. Setup guidance asks users to disable relevant automation and supplies standalone warning placement for custom quest UIs. Loaded-addon detection does not claim to know another addon's enabled settings.

## Remaining gaps and follow-up

The 16 candidates are Open Season #91696; the separate Horde Krol'dok #95056 with incomplete objective data; Counterattack! #4021; The Affray #1719; The Binding #1795; Escape from the Catacombs #9212; Naralex/Wailing Caverns; Bly/Weegli/Zul'Farrak; new dungeon chains; world-refresh/layering behavior; Stranglethorn Fever #349; the two beer quests #1120/#1121; felhound/infernal shard quests #4962/#4963; and Wrath of the Blue Flight #5162. Each has an explicit reason and source in the manifest. The Binding's alternative prerequisite leads #1804/#1805 are recorded but no NPC trigger is invented.

There is likely missing coverage among new Forever quests, class/item/area-trigger events, gameobject interactions, non-quest dungeon gossip and later stages of long escorts. Current field testing should prioritize the low-confidence turn-in timing, new Forever invitations and dungeon restrictions. Known NPC IDs for Naralex and Weegli are recorded, but their encounter/quest association and current action-specific conditions are incomplete. This MVP's runtime rules require a real quest ID; these encounters remain candidates rather than being assigned fake quest IDs.

New evidence should amend both the manifest and readable catalogue and describe what changed. A future implementation should only claim automatic readiness where relevant conditions are observable and false-ready cases have tests. The previous validator and generator were removed with the implementation. Do not upgrade confidence merely because a page URL includes “Forever.”
