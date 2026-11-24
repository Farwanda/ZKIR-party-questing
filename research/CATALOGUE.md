# Researched quest catalogue

Generated from `coverage.json`. Reviewed 23 November 2026 for Forever 1.60.1 / interface 16001.

Research archive: the implementation has been removed. Support labels and proposed automatic checks below preserve the previous assessment, not current functionality or requirements for a new design. References to addon behavior describe the discarded prototype. See the [reuse notes](../README.md#how-to-reuse-the-data).

Empty prerequisite paths mean no verified path is enforced, not proof that no requirements exist. Names are display data; detection uses IDs. Unknown dialogue IDs are deliberately omitted.

## Proposed automatic checks from the previous assessment (8)

### The Defias Brotherhood — #155

Rule: `q155_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Westfall; faction: Alliance; metadata minimum level: 14.
- Trigger: **accept** quest #155; NPC IDs: 467; dialogue-option ID: unverified.
- Required rewarded prerequisites: #142.
- Warning: Accepting this quest sends the Defias Traitor toward the hideout. Everyone must finish their prerequisite hand-in first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: metadata-supported. PARTY_ACCEPT flag 2 plus current general Forever group-offer reports. The addon observes actual delivery after first acceptance; no delivery guarantee.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- Prerequisite paths rewarded, not merely objective-complete.
- Exact quest currently offered at the same observable NPC GUID to every participant.
- Quest absent and a free standard quest-log slot.
- Fresh responding client; no failure, removal or manual hold.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=155); [source 4](https://www.reddit.com/r/wowforever/comments/1xz8td0/escort_quests_should_only_start_when_manually/).

### Rescue OOX-17/TN! — #648

Rule: `q648_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Tanaris; faction: Both; metadata minimum level: 43.
- Trigger: **accept** quest #648; NPC IDs: 7784; dialogue-option ID: unverified.
- Required rewarded prerequisites: #351.
- Warning: Accepting this quest starts the OOX escort. Everyone must hand in the matching distress-beacon quest first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: metadata-supported. PARTY_ACCEPT flag 2 plus current general Forever group-offer reports. The addon observes actual delivery after first acceptance; no delivery guarantee.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- Prerequisite paths rewarded, not merely objective-complete.
- Exact quest currently offered at the same observable NPC GUID to every participant.
- Quest absent and a free standard quest-log slot.
- Fresh responding client; no failure, removal or manual hold.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=648); [source 4](https://www.reddit.com/r/wowforever/comments/1xz8td0/escort_quests_should_only_start_when_manually/).

### The Absent Minded Prospector — #731

Rule: `q731_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Darkshore; faction: Alliance; metadata minimum level: 15.
- Trigger: **accept** quest #731; NPC IDs: 2917; dialogue-option ID: unverified.
- Required rewarded prerequisites: #729.
- Warning: Accepting this step starts Remtravel's escort. Everyone must hand in step #729 before one player accepts #731.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: metadata-supported. PARTY_ACCEPT flag 2 plus current general Forever group-offer reports. The addon observes actual delivery after first acceptance; no delivery guarantee.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- Prerequisite paths rewarded, not merely objective-complete.
- Exact quest currently offered at the same observable NPC GUID to every participant.
- Quest absent and a free standard quest-log slot.
- Fresh responding client; no failure, removal or manual hold.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=731); [source 4](https://www.reddit.com/r/wowforever/comments/1xz8td0/escort_quests_should_only_start_when_manually/).

### Rescue OOX-09/HL! — #836

Rule: `q836_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: The Hinterlands; faction: Both; metadata minimum level: 43.
- Trigger: **accept** quest #836; NPC IDs: 7806; dialogue-option ID: unverified.
- Required rewarded prerequisites: #485.
- Warning: Accepting this quest starts the OOX escort. Everyone must hand in the matching distress-beacon quest first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: metadata-supported. PARTY_ACCEPT flag 2 plus current general Forever group-offer reports. The addon observes actual delivery after first acceptance; no delivery guarantee.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- Prerequisite paths rewarded, not merely objective-complete.
- Exact quest currently offered at the same observable NPC GUID to every participant.
- Quest absent and a free standard quest-log slot.
- Fresh responding client; no failure, removal or manual hold.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=836); [source 4](https://www.reddit.com/r/wowforever/comments/1xz8td0/escort_quests_should_only_start_when_manually/).

### Therylune's Escape — #945

Rule: `q945_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Darkshore; faction: Alliance; metadata minimum level: 10.
- Trigger: **accept** quest #945; NPC IDs: 3584; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Therylune's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: metadata-supported. PARTY_ACCEPT flag 2 plus current general Forever group-offer reports. The addon observes actual delivery after first acceptance; no delivery guarantee.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- Prerequisite paths rewarded, not merely objective-complete.
- Exact quest currently offered at the same observable NPC GUID to every participant.
- Quest absent and a free standard quest-log slot.
- Fresh responding client; no failure, removal or manual hold.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=945); [source 4](https://www.reddit.com/r/wowforever/comments/1xz8td0/escort_quests_should_only_start_when_manually/).

### Rescue OOX-22/FE! — #2767

Rule: `q2767_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Feralas; faction: Both; metadata minimum level: 40.
- Trigger: **accept** quest #2767; NPC IDs: 7807; dialogue-option ID: unverified.
- Required rewarded prerequisites: #2766.
- Warning: Accepting this quest starts the OOX escort. Everyone must hand in the matching distress-beacon quest first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: metadata-supported. PARTY_ACCEPT flag 2 plus current general Forever group-offer reports. The addon observes actual delivery after first acceptance; no delivery guarantee.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- Prerequisite paths rewarded, not merely objective-complete.
- Exact quest currently offered at the same observable NPC GUID to every participant.
- Quest absent and a free standard quest-log slot.
- Fresh responding client; no failure, removal or manual hold.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=2767); [source 4](https://www.reddit.com/r/wowforever/comments/1xz8td0/escort_quests_should_only_start_when_manually/).

### The Sleeper Has Awakened — #5321

Rule: `q5321_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Darkshore; faction: Alliance; metadata minimum level: 17.
- Trigger: **accept** quest #5321; NPC IDs: 11218; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting starts Kerlonian's escort. Gather everyone first; the Horn of Awakening is needed when he falls asleep.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: metadata-supported. PARTY_ACCEPT flag 2 plus current general Forever group-offer reports. The addon observes actual delivery after first acceptance; no delivery guarantee.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- Prerequisite paths rewarded, not merely objective-complete.
- Exact quest currently offered at the same observable NPC GUID to every participant.
- Quest absent and a free standard quest-log slot.
- Fresh responding client; no failure, removal or manual hold.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.
- Bring the Horn of Awakening; item use and NPC sleep are not automated.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=5321); [source 4](https://www.reddit.com/r/wowforever/comments/1xz8td0/escort_quests_should_only_start_when_manually/).

### Freedom to Ruul — #6482

Rule: `q6482_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Ashenvale; faction: Horde; metadata minimum level: 19.
- Trigger: **accept** quest #6482; NPC IDs: 12818; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Ruul's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: metadata-supported. PARTY_ACCEPT flag 2 plus current general Forever group-offer reports. The addon observes actual delivery after first acceptance; no delivery guarantee.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- Prerequisite paths rewarded, not merely objective-complete.
- Exact quest currently offered at the same observable NPC GUID to every participant.
- Quest absent and a free standard quest-log slot.
- Fresh responding client; no failure, removal or manual hold.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=6482); [source 4](https://www.reddit.com/r/wowforever/comments/1xz8td0/escort_quests_should_only_start_when_manually/).

## Warning evidence with unresolved readiness conditions (66)

### Missing In Action — #219

Rule: `q219_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Redridge Mountains; faction: Alliance; metadata minimum level: 19.
- Trigger: **accept** quest #219; NPC IDs: 349; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Corporal Keeshan's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=219).

### Protecting the Shipment — #309

Rule: `q309_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Loch Modan; faction: Alliance; metadata minimum level: 10.
- Trigger: **accept** quest #309; NPC IDs: 1379; dialogue-option ID: unverified.
- Required rewarded prerequisites: #454.
- Warning: Accepting this quest starts Miran's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=309).

### The Attack! — #434

Rule: `q434_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Stormwind City; faction: Alliance; metadata minimum level: 16.
- Trigger: **accept** quest #434; NPC IDs: 7766; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts the garden conversation and confrontation. Gather everyone before Tyrion advances the scene.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.
- QuestieDB links #2746; 60.tools displays a #2745 condition. No guessed OR path is enforced; leader must verify the current offer.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=434); [source 4](https://www.60.tools/quests/434-the-attack).

### Escorting Erland — #435

Rule: `q435_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Silverpine Forest; faction: Horde; metadata minimum level: 10.
- Trigger: **accept** quest #435; NPC IDs: 1978; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Erland's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=435).

### Hints of a New Plague? — #660

Rule: `q660_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Hillsbrad Foothills; faction: Alliance; metadata minimum level: 30.
- Trigger: **accept** quest #660; NPC IDs: 2713; dialogue-option ID: unverified.
- Required rewarded prerequisites: #657.
- Warning: Accepting this quest starts Kinelory's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=660).

### Sunken Treasure — #665

Rule: `q665_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Arathi Highlands; faction: Both; metadata minimum level: 35.
- Trigger: **accept** quest #665; NPC IDs: 2768; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Professor Phizzlethorpe's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=665).

### Death From Below — #667

Rule: `q667_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Arathi Highlands; faction: Both; metadata minimum level: 35.
- Trigger: **accept** quest #667; NPC IDs: 2610; dialogue-option ID: unverified.
- Required rewarded prerequisites: #670.
- Warning: Accepting this quest starts Shakes O'Breen's defense event. Gather everyone before the attacks begin.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=667).

### The Escape — #863

Rule: `q863_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: The Barrens; faction: Both; metadata minimum level: 13.
- Trigger: **accept** quest #863; NPC IDs: 3439; dialogue-option ID: unverified.
- Required rewarded prerequisites: #858.
- Warning: Accepting this quest starts Wizzlecrank's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=863).

### Free From the Hold — #898

Rule: `q898_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: The Barrens; faction: Horde; metadata minimum level: 13.
- Trigger: **accept** quest #898; NPC IDs: 3465; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Gilthares's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=898).

### Mist — #938

Rule: `q938_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Teldrassil; faction: Alliance; metadata minimum level: 7.
- Trigger: **accept** quest #938; NPC IDs: 3568; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Mist's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=938).

### Supplies to Auberdine — #976

Rule: `q976_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Ashenvale; faction: Alliance; metadata minimum level: 19.
- Trigger: **accept** quest #976; NPC IDs: 4484; dialogue-option ID: unverified.
- Required rewarded prerequisites: #973.
- Warning: Accepting this quest starts Feero's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=976).

### Escape Through Force — #994

Rule: `q994_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Darkshore; faction: Alliance; metadata minimum level: 10.
- Trigger: **accept** quest #994; NPC IDs: 3692; dialogue-option ID: unverified.
- Required rewarded prerequisites: #993.
- Warning: Accepting this quest starts Volcor's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=994).

### Escape Through Stealth — #995

Rule: `q995_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Darkshore; faction: Alliance; metadata minimum level: 10.
- Trigger: **accept** quest #995; NPC IDs: 3692; dialogue-option ID: unverified.
- Required rewarded prerequisites: #993.
- Warning: Accepting this quest starts Volcor's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=995).

### Willix the Importer — #1144

Rule: `q1144_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Razorfen Kraul; faction: Both; metadata minimum level: 23.
- Trigger: **accept** quest #1144; NPC IDs: 4508; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Willix's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=1144).

### Stinky's Escape — #1222

Rule: `q1222_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Dustwallow Marsh; faction: Alliance; metadata minimum level: 30.
- Trigger: **accept** quest #1222; NPC IDs: 4880; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Stinky Ignatz's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=1222).

### The Missing Diplomat — #1249

Rule: `q1249_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Wetlands; faction: Alliance; metadata minimum level: 28.
- Trigger: **accept** quest #1249; NPC IDs: 4963; dialogue-option ID: unverified.
- Required rewarded prerequisites: #1248.
- Warning: Accepting this quest starts the confrontation. Gather participants before the NPC flees or combat begins.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=1249).

### Stinky's Escape — #1270

Rule: `q1270_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Dustwallow Marsh; faction: Horde; metadata minimum level: 30.
- Trigger: **accept** quest #1270; NPC IDs: 4880; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Stinky Ignatz's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=1270).

### Questioning Reethe — #1273

Rule: `q1273_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Dustwallow Marsh; faction: Horde; metadata minimum level: 30.
- Trigger: **accept** quest #1273; NPC IDs: 4983; dialogue-option ID: unverified.
- Required rewarded prerequisites: #1269.
- Warning: Accepting this quest starts Ogron's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=1273).

### The Missing Diplomat — #1324

Rule: `q1324_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Dustwallow Marsh; faction: Alliance; metadata minimum level: 28.
- Trigger: **accept** quest #1324; NPC IDs: 4966; dialogue-option ID: unverified.
- Required rewarded prerequisites: #1266.
- Warning: Accepting this quest starts the confrontation. Gather participants before the NPC flees or combat begins.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=1324).

### Galen's Escape — #1393

Rule: `q1393_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Swamp of Sorrows; faction: Both; metadata minimum level: 30.
- Trigger: **accept** quest #1393; NPC IDs: 5391; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Galen's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=1393).

### Return to Vahlarriel — #1440

Rule: `q1440_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Desolace; faction: Alliance; metadata minimum level: 30.
- Trigger: **accept** quest #1440; NPC IDs: 5644; dialogue-option ID: unverified.
- Required rewarded prerequisites: #1439.
- Warning: Accepting this quest starts Dalinda's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=1440).

### Tooga's Quest — #1560

Rule: `q1560_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Tanaris; faction: Both; metadata minimum level: 40.
- Trigger: **accept** quest #1560; NPC IDs: 5955; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Tooga's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=1560).

### Rin'ji is Trapped! — #2742

Rule: `q2742_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: The Hinterlands; faction: Horde; metadata minimum level: 42.
- Trigger: **accept** quest #2742; NPC IDs: 7780; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Rin'ji's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=2742).

### Wandering Shay — #2845

Rule: `q2845_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Feralas; faction: Alliance; metadata minimum level: 44.
- Trigger: **accept** quest #2845; NPC IDs: 7774; dialogue-option ID: unverified.
- Required rewarded prerequisites: #2844.
- Warning: Accepting this quest starts Shay's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=2845).

### A Fine Mess — #2904

Rule: `q2904_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Gnomeregan; faction: Both; metadata minimum level: 24.
- Trigger: **accept** quest #2904; NPC IDs: 7850; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Kernobee's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=2904).

### Suntara Stones — #3367

Rule: `q3367_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Searing Gorge; faction: Alliance; metadata minimum level: 40.
- Trigger: **accept** quest #3367; NPC IDs: 8284; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Dorius's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=3367).

### A Crew Under Fire — #3382

Rule: `q3382_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Azshara; faction: Both; metadata minimum level: 48.
- Trigger: **accept** quest #3382; NPC IDs: 8380; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Captain Vanessa Beltis's defense event. Gather everyone before the attacks begin.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=3382).

### Extinguishing the Idol — #3525

Rule: `q3525_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Razorfen Downs; faction: Both; metadata minimum level: 32.
- Trigger: **accept** quest #3525; NPC IDs: 8516; dialogue-option ID: unverified.
- Required rewarded prerequisites: #3523.
- Warning: Accepting this quest starts Belnistrasz's escort and idol event. Everyone must hand in #3523 first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=3525).

### What Is Going On? — #3982

Rule: `q3982_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Blackrock Depths; faction: Horde; metadata minimum level: 48.
- Trigger: **accept** quest #3982; NPC IDs: 9020; dialogue-option ID: unverified.
- Required rewarded prerequisites: #3981.
- Warning: Accepting this quest starts Gor'shak's defense event. Gather everyone before the attacks begin.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=3982).

### Precarious Predicament — #4121

Rule: `q4121_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Blackrock Depths; faction: Horde; metadata minimum level: 52.
- Trigger: **accept** quest #4121; NPC IDs: 9520; dialogue-option ID: unverified.
- Required rewarded prerequisites: #4122.
- Warning: Accepting this quest starts Grark's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=4121).

### Chasing A-Me 01 — #4245

Rule: `q4245_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Un'Goro Crater; faction: Both; metadata minimum level: 48.
- Trigger: **accept** quest #4245; NPC IDs: 9623; dialogue-option ID: unverified.
- Required rewarded prerequisites: #4244.
- Warning: Accepting this quest starts A-Me 01's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=4245).

### Ancient Spirit — #4261

Rule: `q4261_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Felwood; faction: Alliance; metadata minimum level: 49.
- Trigger: **accept** quest #4261; NPC IDs: 9598; dialogue-option ID: unverified.
- Required rewarded prerequisites: #4442.
- Warning: Accepting this quest starts Arei's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=4261).

### Jail Break! — #4322

Rule: `q4322_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Blackrock Depths; faction: Alliance; metadata minimum level: 50.
- Trigger: **accept** quest #4322; NPC IDs: 9023; dialogue-option ID: unverified.
- Required rewarded prerequisites: #4282.
- Warning: Accepting Jail Break! starts Windsor's escape. Everyone must hand in A Shred of Hope (#4282) first. Check with the group again at Windsor's later dialogue stops.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.
- Mid-escort gossip stops are warning-only; no verified option IDs.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=4322); [source 4](https://www.wowhead.com/forever/quest=4322/jail-break).

### A Little Help From My Friends — #4491

Rule: `q4491_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Un'Goro Crater; faction: Both; metadata minimum level: 50.
- Trigger: **accept** quest #4491; NPC IDs: 9999; dialogue-option ID: unverified.
- Required rewarded prerequisites: #4492.
- Warning: Accepting this quest starts Ringo's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=4491).

### Homeward Bound — #4770

Rule: `q4770_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Thousand Needles; faction: Horde; metadata minimum level: 25.
- Trigger: **accept** quest #4770; NPC IDs: 10427; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Pao'ka's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=4770).

### Guardians of the Altar — #4901

Rule: `q4901_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Winterspring; faction: Alliance; metadata minimum level: 52.
- Trigger: **accept** quest #4901; NPC IDs: 10300; dialogue-option ID: unverified.
- Required rewarded prerequisites: #979.
- Warning: Accepting this quest starts Ranshalla's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=4901).

### Free at Last — #4904

Rule: `q4904_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Thousand Needles; faction: Horde; metadata minimum level: 25.
- Trigger: **accept** quest #4904; NPC IDs: 10646; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Lakota's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=4904).

### Protect Kanati Greycloud — #4966

Rule: `q4966_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Thousand Needles; faction: Horde; metadata minimum level: 23.
- Trigger: **accept** quest #4966; NPC IDs: 10638; dialogue-option ID: unverified.
- Required rewarded prerequisites: #4881.
- Warning: Accepting this quest starts Kanati Greycloud's defense event. Gather everyone before the attacks begin.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=4966).

### Rescue From Jaedenar — #5203

Rule: `q5203_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Felwood; faction: Both; metadata minimum level: 49.
- Trigger: **accept** quest #5203; NPC IDs: 11016; dialogue-option ID: unverified.
- Required rewarded prerequisites: #5202.
- Warning: Accepting this quest starts Arko'narin's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=5203).

### One Shot. One Kill. — #5713

Rule: `q5713_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Darkshore; faction: Alliance; metadata minimum level: 10.
- Trigger: **accept** quest #5713; NPC IDs: 11711; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Sentinel Aynasha's defense event. Gather everyone before the attacks begin.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=5713).

### Bodyguard for Hire — #5821

Rule: `q5821_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Desolace; faction: Both; metadata minimum level: 30.
- Trigger: **accept** quest #5821; NPC IDs: 11625; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts the Gizelton Caravan's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=5821).

### Gizelton Caravan — #5943

Rule: `q5943_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Desolace; faction: Both; metadata minimum level: 32.
- Trigger: **accept** quest #5943; NPC IDs: 11626; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts the Gizelton Caravan's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=5943).

### In Dreams — #5944

Rule: `q5944_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Western Plaguelands; faction: Both; metadata minimum level: 52.
- Trigger: **accept** quest #5944; NPC IDs: 1842; dialogue-option ID: unverified.
- Required rewarded prerequisites: #5862.
- Warning: Accepting this quest starts Taelan's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=5944).

### Get Me Out of Here! — #6132

Rule: `q6132_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Desolace; faction: Both; metadata minimum level: 34.
- Trigger: **accept** quest #6132; NPC IDs: 12277; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Melizza's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=6132).

### The Great Masquerade — #6403

Rule: `q6403_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Stormwind City; faction: Alliance; metadata minimum level: 50.
- Trigger: **accept** quest #6403; NPC IDs: 12580; dialogue-option ID: unverified.
- Required rewarded prerequisites: #6402.
- Warning: Accepting this quest starts Windsor's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=6403).

### Protect Kaya — #6523

Rule: `q6523_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Stonetalon Mountains; faction: Horde; metadata minimum level: 12.
- Trigger: **accept** quest #6523; NPC IDs: 11856; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Kaya's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=6523).

### Torek's Assault — #6544

Rule: `q6544_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Ashenvale; faction: Horde; metadata minimum level: 20.
- Trigger: **accept** quest #6544; NPC IDs: 12858; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Torek's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=6544).

### Vorsha the Lasher — #6641

Rule: `q6641_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Ashenvale; faction: Horde; metadata minimum level: 20.
- Trigger: **accept** quest #6641; NPC IDs: 12717; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Muglash's escort. Gather the participants and finish prerequisite hand-ins first.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=6641).

### The Scepter of Celebras — #7046

Rule: `q7046_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Maraudon; faction: Both; metadata minimum level: 41.
- Trigger: **accept** quest #7046; NPC IDs: 13716; dialogue-option ID: unverified.
- Required rewarded prerequisites: #7044.
- Warning: Accepting this quest starts the scepter ritual with Celebras. Gather all participants before advancing the scene.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=7046).

### Gyromast's Revenge — #2078

Rule: `q2078_dialogue`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Darkshore; faction: Alliance; metadata minimum level: 14.
- Trigger: **dialogue** quest #2078; NPC IDs: 6669; dialogue-option ID: unverified.
- Required rewarded prerequisites: #2098.
- Warning: The key dialogue starts the robot following you; approaching Gelkak then makes it hostile. Accept Gyromast's Revenge before activating it.
- Evidence: Current Forever walkthrough describes key dialogue; Itinerary changelog independently identifies talking to this robot to start the escort.
- Invitation: not-assumed. Each participant must already have #2078. The key dialogue is not ordinary quest sharing.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Hand in #2098, accept #2078, and confirm the key and robot are available.
- Leader confirms everyone is ready before the key dialogue; later hostility near Gelkak is a separate consequence.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.
- Warns at the NPC conversation, not an identified gossip option; leader marks the start after observing it.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=2078); [source 3](https://urgametips.com/wow-forever/quest-guides/gyromasts-revenge-key-threshwackonator-4100-darkshore/); [source 4](https://www.curseforge.com/wow/addons/itinerary/files/9728482).

### The Love Potion — #4201

Rule: `q4201_turnin`. Confidence: medium-low. Reviewed: 2026-11-23.

- Location: Blackrock Depths; faction: Both; metadata minimum level: 50.
- Trigger: **turnin** quest #4201; NPC IDs: 9500; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Reported behavior: handing in starts Nagmara and Rocknot leaving for the tavern-door scene. Check everyone before turning in.
- Evidence: Current Forever quest record retains this quest; inherited quest-specific reports describe the departure on completion. Exact current timing needs field verification.
- Invitation: not-applicable. No acceptance invitation is assumed for a turn-in scene. Confirm each required hand-in before the first one.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Participants should be ready to hand in #4201 before the first turn-in.
- Leader confirms current NPC timing and hand-in availability. No new quest slot is required.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=4201).

### Pyrewood Ambush — #452

Rule: `q452_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Silverpine Forest; faction: Horde; metadata minimum level: 12.
- Trigger: **accept** quest #452; NPC IDs: 2058; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts Deathstalker Faerleia's defense event. Gather everyone before the attacks begin.
- Evidence: Quest objective identifies an escort or NPC defense event; current auto-accept exclusions independently identify this interaction as unsafe to automate. Inherited data is not live script proof.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 3](https://www.wowhead.com/forever/quest=452).

### Spark of Freedom — #87491

Rule: `q87491_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Wetlands; faction: Alliance; metadata minimum level: 25.
- Trigger: **accept** quest #87491; NPC IDs: 271481; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=87491).

### Saving a Sentinel — #88857

Rule: `q88857_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Azshara; faction: Alliance; metadata minimum level: 45.
- Trigger: **accept** quest #88857; NPC IDs: unverified; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=88857).

### Going Home — #93125

Rule: `q93125_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Shen Dralas; faction: Horde; metadata minimum level: 35.
- Trigger: **accept** quest #93125; NPC IDs: 254040; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- Maintain Gelkis reputation; exact threshold not established in this pass.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.
- Rokren escape speed reduced November 17; not evidence of removing acceptance hazard.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=93125).

### This Light of Mine — #93585

Rule: `q93585_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Swamp Of Sorrows; faction: Alliance; metadata minimum level: 30.
- Trigger: **accept** quest #93585; NPC IDs: 255597; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=93585).

### Jom-jom's Escape — #94556

Rule: `q94556_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Riverglades; faction: Horde; metadata minimum level: 36.
- Trigger: **accept** quest #94556; NPC IDs: 258048; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=94556).

### Dunston Checks Out — #94927

Rule: `q94927_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Riverglades; faction: Alliance; metadata minimum level: 38.
- Trigger: **accept** quest #94927; NPC IDs: 259057; dialogue-option ID: unverified.
- Required rewarded prerequisites: #96126.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.
- Dunston running partway through escort was fixed November 20; coordination hazard remains.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=94927); [source 5](https://www.60.tools/quests/94927-dunston-checks-out); [source 6](https://news.blizzard.com/en-us/article/24315281/wow-forever-hotfixes-november-20-2026).

### Krol'dok No More! — #94969

Rule: `q94969_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Unverified; faction: Alliance; metadata minimum level: 40.
- Trigger: **accept** quest #94969; NPC IDs: unverified; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=94969).

### The Windshaper's Wrath — #96204

Rule: `q96204_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Silverpine Forest; faction: Horde; metadata minimum level: 18.
- Trigger: **accept** quest #96204; NPC IDs: 248755; dialogue-option ID: unverified.
- Required rewarded prerequisites: #91862.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.
- Undead Paladin; source also has specific prerequisite #91862.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=96204); [source 5](https://us.forums.blizzard.com/en/wow/t/escort-quests/2356665).

### Escaping the Shadows — #96811

Rule: `q96811_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Blasted Lands; faction: Alliance; metadata minimum level: 45.
- Trigger: **accept** quest #96811; NPC IDs: 266508; dialogue-option ID: unverified.
- Required rewarded prerequisites: #96798.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=96811).

### Zimmix's Great Escape — #97331

Rule: `q97331_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Stranglethorn Vale; faction: Unverified; metadata minimum level: 30.
- Trigger: **accept** quest #97331; NPC IDs: 268992; dialogue-option ID: unverified.
- Required rewarded prerequisites: #97329.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=97331).

### The Longwalkers — #98430

Rule: `q98430_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Mulgore; faction: Horde; metadata minimum level: 1.
- Trigger: **accept** quest #98430; NPC IDs: 272203; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=98430).

### Escaping Ban'ethil — #99053

Rule: `q99053_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Teldrassil; faction: Alliance; metadata minimum level: 4.
- Trigger: **accept** quest #99053; NPC IDs: 275744; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=99053).

### Lost in the Shadows — #99123

Rule: `q99123_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Durotar; faction: Horde; metadata minimum level: 4.
- Trigger: **accept** quest #99123; NPC IDs: 275811; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=99123).

### Seeking Refuge — #99144

Rule: `q99144_accept`. Confidence: medium. Reviewed: 2026-11-23.

- Location: Tirisfal Glades; faction: Horde; metadata minimum level: 5.
- Trigger: **accept** quest #99144; NPC IDs: 275954; dialogue-option ID: unverified.
- Required rewarded prerequisites: not established / none enforced.
- Warning: Accepting this quest starts an escape escort. Finish prerequisite hand-ins and confirm everyone can join first.
- Evidence: Forever-specific escort objective corroborates the current auto-accept exclusion. Missing prerequisite metadata does not prove unrestricted eligibility.
- Invitation: unknown. Observe QUEST_ACCEPT_CONFIRM after first acceptance; never assume ordinary sharing can join a running script.
- Recovery: If credit fails or the quest is removed, verify the log, wait for the NPC to return and begin a new addon attempt. No respawn time or reset guarantee is asserted.
- Every credit seeker must satisfy the current quest offer and hand-in requirements.
- Confirm the same NPC instance and ability to join before the triggering action.
- No live-client verification. NPC range, layering and script availability are not inferred from party proximity.
- Source currently lists Orc or Undead; do not infer all Horde eligibility.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/foreverQuestFixes.lua); [source 3](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 4](https://www.wowhead.com/forever/quest=99144).

## Candidate requiring verification (16)

### Open Season — #91696

Rule: `research_91696_75`. Confidence: unverified. Reviewed: 2026-11-23.

Blacklist-only lead; trigger and NPC evidence insufficient.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua).

### Krol'dok No More! — #95056

Rule: `research_95056_76`. Confidence: unverified. Reviewed: 2026-11-23.

Separate Horde ID has placeholder NAME objective; not conflated with #94969.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua).

### Counterattack! — #4021

Rule: `research_4021_77`. Confidence: unverified. Reviewed: 2026-11-23.

Battle known; exact current dialogue/restart behavior not verified.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=4021).

### The Affray — #1719

Rule: `research_1719_78`. Confidence: unverified. Reviewed: 2026-11-23.

Class/area-trigger event; not one of the verified NPC interaction rules.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=1719).

### The Binding — #1795

Rule: `research_1795_79`. Confidence: unverified. Reviewed: 2026-11-23.

Item-summoned class event, alternatives #1804/#1805; no NPC trigger verified.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=1795).

### Escape from the Catacombs — #9212

Rule: `research_9212_90`. Confidence: unverified. Reviewed: 2026-11-23.

Expansion-era blacklist entry; current Forever applicability not established.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Disciple of Naralex / Wailing Caverns awakening — no quest ID established

Rule: `research_0_92`. Confidence: unverified. Reviewed: 2026-11-23.

Dungeon gossip encounter; quest association and current trigger-option evidence incomplete.
Known NPC IDs: 3678.

Sources: [source 1](https://www.wowhead.com/forever/npc=3678/disciple-of-naralex).

### Prisoner Bly / Weegli Blastfuse / Zul'Farrak — no quest ID established

Rule: `research_0_93`. Confidence: unverified. Reviewed: 2026-11-23.

Dungeon cage/gossip sequence; do not invent quest or dialogue IDs.
Known NPC IDs: 7607.

Sources: [source 1](https://www.wowhead.com/forever/npc=7607/weegli-blastfuse).

### Dun Morogh / new dungeon scripted chains — no quest ID established

Rule: `research_0_94`. Confidence: unverified. Reviewed: 2026-11-23.

New Forever content not exhaustively inventoried; missing interaction evidence.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/src/corrections/Forever/generated/foreverBaseQuest.lua).

### World refresh and layering — no quest ID established

Rule: `research_0_95`. Confidence: unverified. Reviewed: 2026-11-23.

Recent player reports of NPC loss; no reliable exposed prevention or reset API. Not an eligibility rule.

Sources: [source 1](https://www.reddit.com/r/wowforever/comments/1y1q8dx/world_refresh_needs_some_tweaks_for_escort_quests/).

### Stranglethorn Fever — #349

Rule: `candidate_349`. Confidence: unverified. Reviewed: 2026-11-23.

Item-consuming event lead; precise Forever summon dialogue versus acceptance trigger not established.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Get the Gnomes Drunk — #1120

Rule: `candidate_1120`. Confidence: unverified. Reviewed: 2026-11-23.

Automation exclusion; current staged item/quest trigger timing not established.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Get the Goblins Drunk — #1121

Rule: `candidate_1121`. Confidence: unverified. Reviewed: 2026-11-23.

Separate faction beer event; current staged item/quest trigger timing not established.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Shard of a Felhound — #4962

Rule: `candidate_4962`. Confidence: unverified. Reviewed: 2026-11-23.

Class-specific automation exclusion does not establish a coordinated NPC trigger.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Shard of an Infernal — #4963

Rule: `candidate_4963`. Confidence: unverified. Reviewed: 2026-11-23.

Class-specific automation exclusion; current item/event eligibility unverified.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Wrath of the Blue Flight — #5162

Rule: `candidate_5162`. Confidence: unverified. Reviewed: 2026-11-23.

Exclusion describes automatic travel on acceptance; current departure and group consequences need verification.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

## Excluded or obsolete (12)

### Lost! — #4492

Rule: `research_4492_74`. Confidence: high. Reviewed: 2026-11-23.

Travel/hand-in prerequisite for #4491; an auto-accept exclusion alone does not establish an escort on accepting #4492.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Iverron's Antidote — #3521

Rule: `research_3521_80`. Confidence: high. Reviewed: 2026-11-23.

Ordinary collection step; wrong ID for Belnistrasz prerequisite, which is #3523.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=3521).

### Commander Gor'shak — #3981

Rule: `research_3981_81`. Confidence: high. Reviewed: 2026-11-23.

Report-to prerequisite; subsequent #3982 starts the defense.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=3981).

### Rescue OOX-22/FE! — #25476

Rule: `research_25476_82`. Confidence: high. Reviewed: 2026-11-23.

Later expansion version; Forever rescue record is #2767.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Goblin Engineering — #3526

Rule: `research_3526_83`. Confidence: high. Reviewed: 2026-11-23.

Profession choice exclusion; not an escort warning.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Lore for a Price — #2199

Rule: `research_2199_84`. Confidence: high. Reviewed: 2026-11-23.

Material-cost automation exclusion; not evidence of a moving NPC.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).

### Find OOX-17/TN! — #351

Rule: `research_351_85`. Confidence: high. Reviewed: 2026-11-23.

Safe prerequisite hand-in; actual supported escort is #648.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=351).

### Find OOX-09/HL! — #485

Rule: `research_485_86`. Confidence: high. Reviewed: 2026-11-23.

Prerequisite hand-in; escort is #836.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=485).

### Find OOX-22/FE! — #2766

Rule: `research_2766_87`. Confidence: high. Reviewed: 2026-11-23.

Prerequisite hand-in; escort is #2767.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=2766).

### The Absent Minded Prospector — #729

Rule: `research_729_88`. Confidence: high. Reviewed: 2026-11-23.

Report-to step; escort is identically named #731.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=729).

### A Shred of Hope — #4282

Rule: `research_4282_89`. Confidence: high. Reviewed: 2026-11-23.

Hand-in required before #4322; not misclassified as the escort acceptance.

Sources: [source 1](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua); [source 2](https://www.wowhead.com/forever/quest=4282).

### Escape from the Staging Grounds — #10425

Rule: `research_10425_91`. Confidence: high. Reviewed: 2026-11-23.

Outland escort; no current Forever applicability established.

Sources: [source 1](https://github.com/Questie/Questie/blob/master/Modules/Auto/DisallowedIDs.lua); [source 2](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverQuestDB.lua).
