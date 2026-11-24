# Historical escort coverage audit — development build 1.1.0

**Historical catalogue, extended by the [current 1.0 dungeon audit](DUNGEON_AUDIT.md).** The current release incorporates 17 additional rules for a total of 102 and preserves uncertainty for conflicting Willix/Kernobee minimum levels. Release numbering was reset after development build 1.2.0; counts and source conclusions below describe development build 1.1.0 unless corrected in that audit.

Reviewed **24 November 2026**, targeting Forever 1.60.1 / interface 16001. **85 interactions: 77 acceptance, 7 dialogue, 1 turn-in.** Of these, 58 can establish the curated preparation automatically and 27 require assessment of missing details. This is 73 more interactions than 1.0.1, including all 74 entries previously marked supported in the research archive.

This is a bounded research result, not an exhaustive inventory of live Forever scripts. No live client was available. Public quest data, author-maintained corrections, and firsthand reports support the warnings; current timing, invitation delivery, layout, and credit still need [field verification](../docs/MULTIPLAYER_CHECKLIST.md).

## Method and evidence

The review compared the full [102-record research archive](https://github.com/Farwanda/ZKIR-party-questing/blob/main/research/coverage.json) against runtime rules, checked [Questie's automatic-interaction exclusions](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua), and searched inherited quest objectives plus generated/authored Forever corrections for escort, escape, rescue, follow, and defense events. Neither an exclusion nor an event/share flag alone was treated as proof of an acceptance trigger. Profession choices, ordinary report-to steps, expansion replacements, and uncertain item/area triggers were separated from NPC escort starts.

Sources were reconciled in their documented order: [inherited raw records](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua), [legacy corrections](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/legacy/classicQuestFixes.lua), [generated Forever records](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua), then [authored Forever corrections](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua). After implementation, a second programmatic comparison checked all **62 inherited acceptance records** for minimum level, starting NPC, and prerequisite IDs. All **58 automatic rules** have PARTY_ACCEPT=2 in those records and no unhandled class restriction. [Flag definitions](https://github.com/Questie/QuestieDB/blob/master/src/corrections/enum/quests.lua) distinguish an acceptance offer (2) from ordinary sharing (8). Neither guarantees a live offer or eventual credit.

The 15 newer Forever acceptance rules use known IDs and access facts, but incomplete sharing/eligibility evidence prevents automatic Ready. The fallback instruction asks the party to agree how each person joins; it does not promise invitations. Missing NPC identities do not prevent detection at a numeric quest offer.

The [Forever unit API source](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua) was checked for numeric class/race return values. Unavailable or restricted APIs produce Unknown; they are not defaulted to a matching race or class.

## Catalogue

“Automatic” checks preparation for the listed upcoming action, not NPC availability, distance, layers, encounter success, or credit. “Assess details” still opens and synchronizes the normal window, checks known blockers, and explains remaining evidence in the row tooltip. The actual leader confirms that missing information.

A dash under hand-in means no earlier quest is enforced; it is not a claim of unrestricted access. For class events marked “actor,” those prerequisites describe the quest participant: helpers are Unknown until their role is assessed, rather than falsely blocked by the actor's class or quest history. Faction/level entries describe researched quest access, not a restriction on helpers. Questless dungeon rows have no fabricated quest ID.

| Interaction | Quest | NPC / source object | Warning before | Minimum level / faction | Earlier hand-in | Preparation |
| --- | --- | --- | --- | --- | --- | --- |
| The Defias Brotherhood | [155](https://www.wowhead.com/forever/quest=155) | [467](https://www.wowhead.com/forever/npc=467) | accept | 14 / Alliance | 142 | Automatic |
| Missing In Action | [219](https://www.wowhead.com/forever/quest=219) | [349](https://www.wowhead.com/forever/npc=349) | accept | 19 / Alliance | — | Automatic |
| Protecting the Shipment | [309](https://www.wowhead.com/forever/quest=309) | [1379](https://www.wowhead.com/forever/npc=1379) | accept | 10 / Alliance | 454 | Automatic |
| Escorting Erland | [435](https://www.wowhead.com/forever/quest=435) | [1978](https://www.wowhead.com/forever/npc=1978) | accept | 10 / Horde | — | Automatic |
| Pyrewood Ambush | [452](https://www.wowhead.com/forever/quest=452) | [2058](https://www.wowhead.com/forever/npc=2058) | accept | 12 / Horde | — | Automatic |
| Rescue OOX-17/TN! | [648](https://www.wowhead.com/forever/quest=648) | [7784](https://www.wowhead.com/forever/npc=7784) | accept | 43 / Both | 351 | Automatic |
| Hints of a New Plague? | [660](https://www.wowhead.com/forever/quest=660) | [2713](https://www.wowhead.com/forever/npc=2713) | accept | 30 / Alliance | 657 | Automatic |
| Sunken Treasure | [665](https://www.wowhead.com/forever/quest=665) | [2768](https://www.wowhead.com/forever/npc=2768) | accept | 35 / Both | 663 | Automatic |
| Death From Below | [667](https://www.wowhead.com/forever/quest=667) | [2610](https://www.wowhead.com/forever/npc=2610) | accept | 35 / Both | 670 | Automatic |
| The Absent Minded Prospector | [731](https://www.wowhead.com/forever/quest=731) | [2917](https://www.wowhead.com/forever/npc=2917) | accept | 15 / Alliance | 729 | Automatic |
| Rescue OOX-09/HL! | [836](https://www.wowhead.com/forever/quest=836) | [7806](https://www.wowhead.com/forever/npc=7806) | accept | 43 / Both | 485 | Automatic |
| The Escape | [863](https://www.wowhead.com/forever/quest=863) | [3439](https://www.wowhead.com/forever/npc=3439) | accept | 13 / Both | 858 | Automatic |
| Free From the Hold | [898](https://www.wowhead.com/forever/quest=898) | [3465](https://www.wowhead.com/forever/npc=3465) | accept | 13 / Horde | — | Automatic |
| Mist | [938](https://www.wowhead.com/forever/quest=938) | [3568](https://www.wowhead.com/forever/npc=3568) | accept | 7 / Alliance | — | Automatic |
| Therylune's Escape | [945](https://www.wowhead.com/forever/quest=945) | [3584](https://www.wowhead.com/forever/npc=3584) | accept | 10 / Alliance | — | Automatic |
| Supplies to Auberdine | [976](https://www.wowhead.com/forever/quest=976) | [4484](https://www.wowhead.com/forever/npc=4484) | accept | 19 / Alliance | 973 | Automatic |
| Escape Through Force | [994](https://www.wowhead.com/forever/quest=994) | [3692](https://www.wowhead.com/forever/npc=3692) | accept | 10 / Alliance | 993 | Automatic |
| Escape Through Stealth | [995](https://www.wowhead.com/forever/quest=995) | [3692](https://www.wowhead.com/forever/npc=3692) | accept | 10 / Alliance | 993 | Automatic |
| Gerenzo's Orders | [1090](https://www.wowhead.com/forever/quest=1090) | [4276](https://www.wowhead.com/forever/npc=4276) | accept | 17 / Both | — | Automatic |
| Willix the Importer | [1144](https://www.wowhead.com/forever/quest=1144) | [4508](https://www.wowhead.com/forever/npc=4508) | accept | 23 / Both | — | Automatic |
| Stinky's Escape | [1222](https://www.wowhead.com/forever/quest=1222) | [4880](https://www.wowhead.com/forever/npc=4880) | accept | 30 / Alliance | — | Automatic |
| The Missing Diplomat | [1249](https://www.wowhead.com/forever/quest=1249) | [4963](https://www.wowhead.com/forever/npc=4963) | accept | 28 / Alliance | 1248 | Automatic |
| Stinky's Escape | [1270](https://www.wowhead.com/forever/quest=1270) | [4880](https://www.wowhead.com/forever/npc=4880) | accept | 30 / Horde | — | Automatic |
| Questioning Reethe | [1273](https://www.wowhead.com/forever/quest=1273) | [4983](https://www.wowhead.com/forever/npc=4983) | accept | 30 / Horde | 1269 | Automatic |
| The Missing Diplomat | [1324](https://www.wowhead.com/forever/quest=1324) | [4966](https://www.wowhead.com/forever/npc=4966) | accept | 28 / Alliance | 1266 | Automatic |
| Galen's Escape | [1393](https://www.wowhead.com/forever/quest=1393) | [5391](https://www.wowhead.com/forever/npc=5391) | accept | 30 / Both | — | Automatic |
| Return to Vahlarriel | [1440](https://www.wowhead.com/forever/quest=1440) | [5644](https://www.wowhead.com/forever/npc=5644) | accept | 30 / Alliance | 1439 | Automatic |
| Tooga's Quest | [1560](https://www.wowhead.com/forever/quest=1560) | [5955](https://www.wowhead.com/forever/npc=5955) | accept | 40 / Both | — | Automatic |
| The Tome of Valor | [1651](https://www.wowhead.com/forever/quest=1651) | [6182](https://www.wowhead.com/forever/npc=6182) | accept | 20 / Alliance | 1650 (actor) | Assess details |
| Rin'ji is Trapped! | [2742](https://www.wowhead.com/forever/quest=2742) | [7780](https://www.wowhead.com/forever/npc=7780) | accept | 42 / Horde | — | Automatic |
| Rescue OOX-22/FE! | [2767](https://www.wowhead.com/forever/quest=2767) | [7807](https://www.wowhead.com/forever/npc=7807) | accept | 40 / Both | 2766 | Automatic |
| Wandering Shay | [2845](https://www.wowhead.com/forever/quest=2845) | [7774](https://www.wowhead.com/forever/npc=7774) | accept | 44 / Alliance | 2844 | Automatic |
| A Fine Mess | [2904](https://www.wowhead.com/forever/quest=2904) | [7850](https://www.wowhead.com/forever/npc=7850) | accept | 24 / Both | — | Automatic |
| Freedom for All Creatures | [2969](https://www.wowhead.com/forever/quest=2969) | [7956](https://www.wowhead.com/forever/npc=7956) | accept | 38 / Alliance | — | Automatic |
| Suntara Stones | [3367](https://www.wowhead.com/forever/quest=3367) | [8284](https://www.wowhead.com/forever/npc=8284) | accept | 40 / Alliance | — | Automatic |
| A Crew Under Fire | [3382](https://www.wowhead.com/forever/quest=3382) | [8380](https://www.wowhead.com/forever/npc=8380) | accept | 48 / Both | — | Assess details |
| Extinguishing the Idol | [3525](https://www.wowhead.com/forever/quest=3525) | [8516](https://www.wowhead.com/forever/npc=8516) | accept | 32 / Both | 3523 | Automatic |
| What Is Going On? | [3982](https://www.wowhead.com/forever/quest=3982) | [9020](https://www.wowhead.com/forever/npc=9020) | accept | 48 / Horde | 3981 | Automatic |
| Precarious Predicament | [4121](https://www.wowhead.com/forever/quest=4121) | [9520](https://www.wowhead.com/forever/npc=9520) | accept | 52 / Horde | 4122 | Automatic |
| Chasing A-Me 01 | [4245](https://www.wowhead.com/forever/quest=4245) | [9623](https://www.wowhead.com/forever/npc=9623) | accept | 48 / Both | 4244 | Automatic |
| Ancient Spirit | [4261](https://www.wowhead.com/forever/quest=4261) | [9598](https://www.wowhead.com/forever/npc=9598) | accept | 49 / Alliance | 4442 | Automatic |
| Freed from the Hive | [4265](https://www.wowhead.com/forever/quest=4265) | Object 164954 | accept | 40 / Alliance | 4135 | Assess details |
| Jail Break! | [4322](https://www.wowhead.com/forever/quest=4322) | [9023](https://www.wowhead.com/forever/npc=9023) | accept | 50 / Alliance | 4282 | Automatic |
| A Little Help From My Friends | [4491](https://www.wowhead.com/forever/quest=4491) | [9999](https://www.wowhead.com/forever/npc=9999) | accept | 50 / Both | 4492 | Automatic |
| Homeward Bound | [4770](https://www.wowhead.com/forever/quest=4770) | [10427](https://www.wowhead.com/forever/npc=10427) | accept | 25 / Horde | — | Automatic |
| Guardians of the Altar | [4901](https://www.wowhead.com/forever/quest=4901) | [10300](https://www.wowhead.com/forever/npc=10300) | accept | 52 / Alliance | 979 | Automatic |
| Free at Last | [4904](https://www.wowhead.com/forever/quest=4904) | [10646](https://www.wowhead.com/forever/npc=10646) | accept | 25 / Horde | — | Automatic |
| Protect Kanati Greycloud | [4966](https://www.wowhead.com/forever/quest=4966) | [10638](https://www.wowhead.com/forever/npc=10638) | accept | 23 / Horde | 4881 | Automatic |
| Rescue From Jaedenar | [5203](https://www.wowhead.com/forever/quest=5203) | [11016](https://www.wowhead.com/forever/npc=11016) | accept | 49 / Both | 5202 | Automatic |
| The Sleeper Has Awakened | [5321](https://www.wowhead.com/forever/quest=5321) | [11218](https://www.wowhead.com/forever/npc=11218) | accept | 17 / Alliance | — | Automatic |
| One Shot. One Kill. | [5713](https://www.wowhead.com/forever/quest=5713) | [11711](https://www.wowhead.com/forever/npc=11711) | accept | 10 / Alliance | — | Automatic |
| Bodyguard for Hire | [5821](https://www.wowhead.com/forever/quest=5821) | [11625](https://www.wowhead.com/forever/npc=11625) | accept | 30 / Both | — | Automatic |
| Gizelton Caravan | [5943](https://www.wowhead.com/forever/quest=5943) | [11626](https://www.wowhead.com/forever/npc=11626) | accept | 32 / Both | — | Automatic |
| In Dreams | [5944](https://www.wowhead.com/forever/quest=5944) | [1842](https://www.wowhead.com/forever/npc=1842) | accept | 52 / Both | 5862 | Automatic |
| Get Me Out of Here! | [6132](https://www.wowhead.com/forever/quest=6132) | [12277](https://www.wowhead.com/forever/npc=12277) | accept | 34 / Both | — | Automatic |
| The Great Masquerade | [6403](https://www.wowhead.com/forever/quest=6403) | [12580](https://www.wowhead.com/forever/npc=12580) | accept | 50 / Alliance | 6402 | Automatic |
| Freedom to Ruul | [6482](https://www.wowhead.com/forever/quest=6482) | [12818](https://www.wowhead.com/forever/npc=12818) | accept | 19 / Horde | — | Automatic |
| Protect Kaya | [6523](https://www.wowhead.com/forever/quest=6523) | [11856](https://www.wowhead.com/forever/npc=11856) | accept | 12 / Horde | — | Automatic |
| Torek's Assault | [6544](https://www.wowhead.com/forever/quest=6544) | [12858](https://www.wowhead.com/forever/npc=12858) | accept | 20 / Horde | — | Automatic |
| Vorsha the Lasher | [6641](https://www.wowhead.com/forever/quest=6641) | [12717](https://www.wowhead.com/forever/npc=12717) | accept | 20 / Horde | — | Automatic |
| The Scepter of Celebras | [7046](https://www.wowhead.com/forever/quest=7046) | [13716](https://www.wowhead.com/forever/npc=13716) | accept | 41 / Both | 7044 | Automatic |
| The Balance of Light and Shadow | [7622](https://www.wowhead.com/forever/quest=7622) | [14494](https://www.wowhead.com/forever/npc=14494) | accept | 60 / Both | — (actor) | Assess details |
| Spark of Freedom | [87491](https://www.wowhead.com/forever/quest=87491) | [271481](https://www.wowhead.com/forever/npc=271481) | accept | 25 / Alliance | — | Assess details |
| Saving a Sentinel | [88857](https://www.wowhead.com/forever/quest=88857) | Unverified | accept | 45 / Alliance | — | Assess details |
| Open Season | [91696](https://www.wowhead.com/forever/quest=91696) | [244425](https://www.wowhead.com/forever/npc=244425) | accept | 54 / Unverified | 91698 | Assess details |
| Going Home | [93125](https://www.wowhead.com/forever/quest=93125) | [254040](https://www.wowhead.com/forever/npc=254040) | accept | 35 / Horde | — | Assess details |
| This Light of Mine | [93585](https://www.wowhead.com/forever/quest=93585) | [255597](https://www.wowhead.com/forever/npc=255597) | accept | 30 / Alliance | — | Assess details |
| Jom-jom's Escape | [94556](https://www.wowhead.com/forever/quest=94556) | [258048](https://www.wowhead.com/forever/npc=258048) | accept | 36 / Horde | — | Assess details |
| Dunston Checks Out | [94927](https://www.wowhead.com/forever/quest=94927) | [259057](https://www.wowhead.com/forever/npc=259057) | accept | 38 / Alliance | 96126 | Assess details |
| Krol'dok No More! | [94969](https://www.wowhead.com/forever/quest=94969) | Unverified | accept | 40 / Alliance | — | Assess details |
| The Windshaper's Wrath | [96204](https://www.wowhead.com/forever/quest=96204) | [248755](https://www.wowhead.com/forever/npc=248755) | accept | 18 / Horde | 91862 (actor) | Assess details |
| Escaping the Shadows | [96811](https://www.wowhead.com/forever/quest=96811) | [266508](https://www.wowhead.com/forever/npc=266508) | accept | 45 / Alliance | 96798 | Assess details |
| Zimmix's Great Escape | [97331](https://www.wowhead.com/forever/quest=97331) | [268992](https://www.wowhead.com/forever/npc=268992) | accept | 30 / Unverified | 97329 | Assess details |
| The Longwalkers | [98430](https://www.wowhead.com/forever/quest=98430) | [272203](https://www.wowhead.com/forever/npc=272203) | accept | 1 / Horde | — | Assess details |
| Escaping Ban'ethil | [99053](https://www.wowhead.com/forever/quest=99053) | [275744](https://www.wowhead.com/forever/npc=275744) | accept | 4 / Alliance | — | Assess details |
| Lost in the Shadows | [99123](https://www.wowhead.com/forever/quest=99123) | [275811](https://www.wowhead.com/forever/npc=275811) | accept | 4 / Horde | — | Assess details |
| Seeking Refuge | [99144](https://www.wowhead.com/forever/quest=99144) | [275954](https://www.wowhead.com/forever/npc=275954) | accept | 5 / Horde | — | Assess details |
| The Attack! | [434](https://www.wowhead.com/forever/quest=434) | [7766](https://www.wowhead.com/forever/npc=7766) | gossip | — / Unverified | — | Assess details |
| Gyromast's Revenge | [2078](https://www.wowhead.com/forever/quest=2078) | [6669](https://www.wowhead.com/forever/npc=6669) | gossip | — / Unverified | 2098 | Assess details |
| Awakening Naralex | — | [3678](https://www.wowhead.com/forever/npc=3678) | gossip | — / Unverified | — | Assess details |
| Shadowfang courtyard: Adamant | — | [3849](https://www.wowhead.com/forever/npc=3849) | gossip | — / Unverified | — | Assess details |
| Shadowfang courtyard: Ashcrombe | — | [3850](https://www.wowhead.com/forever/npc=3850) | gossip | — / Unverified | — | Assess details |
| Bly's confrontation | — | [7604](https://www.wowhead.com/forever/npc=7604) | gossip | — / Unverified | — | Assess details |
| Weegli's demolition | — | [7607](https://www.wowhead.com/forever/npc=7607) | gossip | — / Unverified | — | Assess details |
| The Love Potion | [4201](https://www.wowhead.com/forever/quest=4201) | [9500](https://www.wowhead.com/forever/npc=9500) | turnin | — / Unverified | — | Assess details |

## Corrections and additional findings

- **A-Me and Ringo:** A-Me #4245 follows repair hand-in #4244; Ringo #4491 follows #4492. Earlier steps and same-title records are not themselves the escort acceptance. Completing prerequisite objectives is insufficient.
- **Sunken Treasure #665:** the legacy correction supplies prerequisite #663, absent from the raw record and older archive. The runtime now enforces that hand-in.
- **Volcor #994/#995:** mutually exclusive branches are checked. When both hazardous offers are visible, the addon waits for the selected quest detail screen before opening a specific event, still before Accept.
- **Windsor:** #4322 requires #4282; #6403 requires #6402 and conflicts with Forever branch #99435. The [historical Stormwind script](https://github.com/cmangos/mangos-classic/blob/master/src/game/AI/ScriptDevAI/scripts/eastern_kingdoms/stormwind_city.cpp) distinguishes acceptance starting the march from the later keep dialogue. It is historical corroboration, not proof of current server code; later pauses remain separate field checks.
- **The Attack! #434:** [Forever firsthand reports](https://www.wowhead.com/forever/quest=434/the-attack) describe accepting first, then asking Tyrion to begin. The runtime uses NPC #7766 conversation, not an acceptance warning. Known absence of #434 suppresses an irrelevant visit; unavailable quest state still warns and stays Unknown. No current option ID or precise scene state is invented.
- **Open Season #91696:** [quest text and firsthand reports](https://www.wowhead.com/forever/quest=91696/open-season) establish the Barkskin family escort. The authored correction supplies #91698, [Barkskin Breakout](https://www.wowhead.com/forever/quest=91698/barkskin-breakout), as its prerequisite; NPC #244425 is the Barkskin Matriarch. The post-implementation pass caught this missing prerequisite and added it. Reports suggest reputation affects access; no threshold is enforced without sufficient evidence.
- **Other additional acceptance leads:** [Gerenzo's Orders #1090](https://www.wowhead.com/forever/quest=1090/gerenzos-orders) starts Piznik's defense; [Freedom for All Creatures #2969](https://www.wowhead.com/forever/quest=2969/freedom-for-all-creatures) has Kindal follow with a timer before the later cage interaction. [Freed from the Hive #4265](https://www.wowhead.com/forever/quest=4265/freed-from-the-hive) is a pod-offered release scene, with historical reports of a brief window. Its warning labels the consequence as reported and cannot precede opening/attacking the pod.
- **Class events:** [Daphne #1651](https://www.wowhead.com/forever/quest=1651/the-tome-of-valor), Lumina #96204, and [Eris #7622](https://www.wowhead.com/forever/quest=7622/the-balance-of-light-and-shadow) need participant/helper assessment. Eris also has special access/interference mechanics. The addon does not infer that ordinary outside assistance is safe or force helpers to qualify for the actor's quest. A held failed quest remains a verified blocker.
- **Repeatability:** #3382 is a repeatable defense and remains Unknown for the current attempt even after an earlier completion. #3982's authored Forever correction clears its inherited repeatable flag; previous hand-in remains a blocker there.
- **New access corrections:** #99053 uses the authored all-Alliance correction over the narrower generated race mask. #99144 retains the sourced Orc/Undead restriction; missing race API stays Unknown. #97331's generated all-races mask is explicitly an assumption, so faction access is left unverified. #93125's Gelkis reputation requirement is flagged for assessment without inventing a threshold.
- **Caravans:** [#5821](https://www.wowhead.com/forever/quest=5821/bodyguard-for-hire) and [#5943](https://www.wowhead.com/forever/quest=5943/gizelton-caravan) are ambush legs of a scheduled caravan. Warnings tell players to gather at its quest stop; they do not imply the addon pauses the route.
- **Dungeon dialogue:** [Naralex's Disciple #3678](https://www.wowhead.com/forever/npc=3678/disciple-of-naralex), [Adamant #3849](https://www.wowhead.com/forever/npc=3849/deathstalker-adamant), [Ashcrombe #3850](https://www.wowhead.com/forever/npc=3850/sorcerer-ashcrombe), [Bly #7604](https://www.wowhead.com/forever/npc=7604/sergeant-bly), and [Weegli #7607](https://www.wowhead.com/forever/npc=7607/weegli-blastfuse) now warn on conversation open. Evidence includes quest/NPC text and firsthand reports, many inherited from earlier clients. Naralex's boss progress, prisoner availability, and Weegli's demolition state remain Unknown; the later Naralex drop quest is not used as an eligibility proxy. The warning can appear when an NPC has no start option yet. Any observed option selection conservatively retires that preparation.

The [historical 1.0.1 audit](IMPLEMENTATION_REVIEW.md) retains the original API review and Celebras, Kerlonian, OOX, Gyromast, and Love Potion findings. Its twelve-rule inventory and release-specific exclusions are superseded here.

## Remaining gaps and explicit exclusions

| Lead / interaction | Current boundary |
| --- | --- |
| Generic cage, pod, item-use, altar, torch, or brazier activation | No generic pre-click interception. #2969/#4265 warn at their quest offers; ZF prisoner cage opening is not covered by the later Bly/Weegli dialogue warnings. |
| Later escort pauses, including Windsor/Ranshalla/Muglash | Initial warning reminds the party to regroup; later stage/option detection is not implemented. |
| #95056 Krol'dok No More! | [Published record](https://www.wowhead.com/forever/quest=95056/kroldok-no-more) has NYI/placeholder content. Not conflated with supported Alliance #94969. |
| #4021 Counterattack!; #349 Stranglethorn Fever | Precise current dialogue/restart or item-consuming trigger still needs verification. No guessed acceptance rule. |
| #1719; #1795; #4962/#4963; #1120/#1121; #5162 | Area, item, class, beer-event, or travel leads do not yet establish a supported NPC escort start. |
| #8736 The Nightmare Manifests | [Raid-scale event](https://www.wowhead.com/forever/quest=8736/the-nightmare-manifests); outside this addon's 2–5-player coordination scope. |
| #9212; #10425; #25476 | Expansion-era records without verified current applicability; #2767 is the supported Feralas OOX version. |
| New Forever dungeon chains / undiscovered quests | Public records do not provide a complete script inventory. A missing warning is possible; record the numeric quest/NPC and the exact action for research. |
| Layer changes, world refresh, resets, other automation | Not prevented. Disable automatic accept/turn-in/dialogue addons for coordinated interactions. |

## Verification and maintenance

The Lua 5.1 suite runs **26 protocol groups**, **15 mocked adapter/UI groups**, **199 catalogue preparation/message checks**, and **20 preparation cases**. It exercises all 85 interactions in mixed-addon parties, leader-only announcements, manual provenance, and retirement after the corresponding action; every acceptance rule is also opened through the mocked real adapter before any action. New regressions cover mutually exclusive choices, missing race/quest APIs, repeatability, class helpers, questless NPCs, and the Open Season hand-in. Existing tests continue checking retries, reloads, leader/member changes, lost messages, and unrelated quest updates.

A coverage gate fails if a previously supported archive record disappears from runtime rules, with #434's documented trigger change handled explicitly. The archive is retained as historical evidence; its candidate/status labels are not the current release inventory. Future additions must establish the action and relevant facts before enabling automatic readiness.

The install ZIP contains this audit and the multiplayer checklist. All test results are simulated; **no in-game multiplayer case is marked passed**.

Source snapshots used for the data comparison (upstream files are not bundled):

| Source | SHA-256 |
| --- | --- |
| Forever raw quest DB | `621d4a1670232c047e7d171d8f1fdbd31581458935ee59dd70836016838dc942` |
| Auto exclusions | `b1e7ee499cd4b9a8229b0a7f7b2ee89cc68ac57a40f885b18ff489865557f0a8` |
| Generated Forever base | `197dff16946293da0cd23722578cb383a498c6e8d046fc49a96a3777883a66c2` |
| Authored Forever fixes | `03c9fa06e1590b18cd18d2961f967ea2e0f562c9668cef22180410af07357ed0` |
| Legacy corrections | `76cd6a05f035826cabc6180a0ff2a1a37c5e7946c891eb0a06412fab5a4caf2e` |
