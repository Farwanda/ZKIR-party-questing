local _, NS = ...

-- Curated factual IDs. See research/ESCORT_COVERAGE.md and DUNGEON_AUDIT.md.
-- PARTY_ACCEPT metadata supports an offer; it does not guarantee delivery or credit.
local rules = {}
local function escort(id, npc, title, previous, level, faction, consequence, options)
    options = options or {}
    local key = "a" .. id
    rules[key] = {id = key, questID = id, npcID = npc, title = title, kind = "accept",
        prerequisites = previous and {previous} or {}, minLevel = level, faction = faction,
        alternativeMinLevel = options.alternativeMinLevel,
        automatic = options.automatic ~= false and options.partyAccept ~= false,
        partyAccept = options.partyAccept ~= false, details = options.details,
        prerequisiteNames = options.prerequisiteNames,
        exclusive = options.exclusive, repeatable = options.repeatable,
        classID = options.classID, raceIDs = options.raceIDs, participantRoles = options.participantRoles,
        consequence = consequence, nextStep = options.nextStep}
end
-- New Forever quests have incomplete sharing/access metadata. Warn normally,
-- exchange known facts, and leave the remaining preparation to the leader.
local function uncertainEscort(id, npc, title, previous, level, faction, consequence, options)
    options = options or {}
    options.partyAccept = false
    options.details = options.details or
        "Verify current quest access and how each player joins; party invitations and full eligibility are unverified."
    escort(id, npc, title, previous, level, faction, consequence, options)
end
escort(155, 467, "The Defias Brotherhood", 142, 14, "Alliance", "Accepting starts the escort.")
escort(648, 7784, "Rescue OOX-17/TN!", 351, 43, "Both", "Accepting starts the escort.")
escort(731, 2917, "The Absent Minded Prospector", 729, 15, "Alliance", "Accepting starts the escort.")
escort(836, 7806, "Rescue OOX-09/HL!", 485, 43, "Both", "Accepting starts the escort.")
escort(945, 3584, "Therylune's Escape", nil, 10, "Alliance", "Accepting starts the escort.")
escort(2767, 7807, "Rescue OOX-22/FE!", 2766, 40, "Both", "Accepting starts the escort.")
escort(4245, 9623, "Chasing A-Me 01", 4244, 48, "Both", "Accepting starts the escort.",
    {details = "Hand in the Mithril Casing repair step #4244 first; carrying a casing is not enough."})
escort(5321, 11218, "The Sleeper Has Awakened", nil, 17, "Alliance", "Accepting starts the escort.",
    {details = "Check Kerlonian's supplies before starting."})
escort(6482, 12818, "Freedom to Ruul", nil, 19, "Horde", "Accepting starts the escort.")
escort(7046, 13716, "The Scepter of Celebras", 7044, 41, "Both", "Accepting starts a long ritual.",
    {prerequisiteNames = {[7044] = "Legends of Maraudon"}})
-- Expanded acceptance catalogue; see research/ESCORT_COVERAGE.md for sources and gaps.
escort(219, 349, "Missing In Action", nil, 19, "Alliance", "Accepting starts the escort.")
escort(309, 1379, "Protecting the Shipment", 454, 10, "Alliance", "Accepting starts the escort.")
escort(435, 1978, "Escorting Erland", nil, 10, "Horde", "Accepting starts the escort.")
escort(660, 2713, "Hints of a New Plague?", 657, 30, "Alliance", "Accepting starts the escort.")
escort(665, 2768, "Sunken Treasure", 663, 35, "Both", "Accepting starts the escort.")
escort(667, 2610, "Death From Below", 670, 35, "Both", "Accepting starts the defense.")
escort(863, 3439, "The Escape", 858, 13, "Both", "Accepting starts the escort.")
escort(898, 3465, "Free From the Hold", nil, 13, "Horde", "Accepting starts the escort.")
escort(938, 3568, "Mist", nil, 7, "Alliance", "Accepting starts the escort.")
escort(976, 4484, "Supplies to Auberdine", 973, 19, "Alliance", "Accepting starts the escort.")
escort(994, 3692, "Escape Through Force", 993, 10, "Alliance", "Accepting starts the escort.", {exclusive = {995}})
escort(995, 3692, "Escape Through Stealth", 993, 10, "Alliance", "Accepting starts the escort.", {exclusive = {994}})
escort(1144, 4508, "Willix the Importer", nil, 23, "Both", "Accepting starts the escort.",
    {alternativeMinLevel = 22, details = "Sources disagree on minimum level (22 or 23). Verify acceptance access for a level-22 player."})
escort(1222, 4880, "Stinky's Escape", nil, 30, "Alliance", "Accepting starts the escort.")
escort(1249, 4963, "The Missing Diplomat", 1248, 28, "Alliance", "Accepting starts the fight.")
escort(1270, 4880, "Stinky's Escape", nil, 30, "Horde", "Accepting starts the escort.")
escort(1273, 4983, "Questioning Reethe", 1269, 30, "Horde", "Accepting starts the escort.")
escort(1324, 4966, "The Missing Diplomat", 1266, 28, "Alliance", "Accepting starts the fight.")
escort(1393, 5391, "Galen's Escape", nil, 30, "Both", "Accepting starts the escort.")
escort(1440, 5644, "Return to Vahlarriel", 1439, 30, "Alliance", "Accepting starts the escort.")
escort(1560, 5955, "Tooga's Quest", nil, 40, "Both", "Accepting starts the escort.")
escort(2742, 7780, "Rin'ji is Trapped!", nil, 42, "Horde", "Accepting starts the escort.")
escort(2845, 7774, "Wandering Shay", 2844, 44, "Alliance", "Accepting starts the escort.")
escort(2904, 7850, "A Fine Mess", nil, 24, "Both", "Accepting starts the escort.",
    {alternativeMinLevel = 20, details = "Sources disagree on minimum level (20 or 24). Verify acceptance access for players at levels 20-23."})
escort(3367, 8284, "Suntara Stones", nil, 40, "Alliance", "Accepting starts the escort.")
escort(3382, 8380, "A Crew Under Fire", nil, 48, "Both", "Accepting starts the defense.", {repeatable = true, automatic = false, details = "Repeatable defense: verify the current attack and that everyone can join this attempt."})
escort(3525, 8516, "Extinguishing the Idol", 3523, 32, "Both", "Accepting starts the escort and ritual.")
escort(3982, 9020, "What Is Going On?", 3981, 48, "Horde", "Accepting starts the defense.")
escort(4121, 9520, "Precarious Predicament", 4122, 52, "Horde", "Accepting starts the escort.")
escort(4261, 9598, "Ancient Spirit", 4442, 49, "Alliance", "Accepting starts the escort.")
escort(4322, 9023, "Jail Break!", 4282, 50, "Alliance", "Accepting starts Windsor's escape.",
    {details = "Regroup at Windsor's later dialogue stops."})
escort(4491, 9999, "A Little Help From My Friends", 4492, 50, "Both", "Accepting starts the escort.",
    {details = "Check the supplies needed when Ringo faints."})
escort(4770, 10427, "Homeward Bound", nil, 25, "Horde", "Accepting starts the escort.")
escort(4901, 10300, "Guardians of the Altar", 979, 52, "Alliance", "Accepting starts the escort.",
    {details = "Regroup at Ranshalla's later torch and altar stops."})
escort(4904, 10646, "Free at Last", nil, 25, "Horde", "Accepting starts the escort.")
escort(4966, 10638, "Protect Kanati Greycloud", 4881, 23, "Horde", "Accepting starts the defense.")
escort(5203, 11016, "Rescue From Jaedenar", 5202, 49, "Both", "Accepting starts the escort.")
escort(5713, 11711, "One Shot. One Kill.", nil, 10, "Alliance", "Accepting starts the defense.")
escort(5821, 11625, "Bodyguard for Hire", nil, 30, "Both", "The caravan heads into an ambush.",
    {details = "Gather everyone at the caravan's quest stop."})
escort(5943, 11626, "Gizelton Caravan", nil, 32, "Both", "The caravan heads into an ambush.",
    {details = "Gather everyone at the quest stop before the Mannoroc ambush."})
escort(5944, 1842, "In Dreams", 5862, 52, "Both", "Accepting starts the escort.")
escort(6132, 12277, "Get Me Out of Here!", nil, 34, "Both", "Accepting starts the escort.")
escort(6403, 12580, "The Great Masquerade", 6402, 50, "Alliance", "Accepting starts Windsor's march.",
    {exclusive = {99435}, details = "Regroup before Windsor's later dialogue at the keep."})
escort(6523, 11856, "Protect Kaya", nil, 12, "Horde", "Accepting starts the escort.")
escort(6544, 12858, "Torek's Assault", nil, 20, "Horde", "Accepting starts the escort.")
escort(6641, 12717, "Vorsha the Lasher", nil, 20, "Horde", "Accepting starts the escort.",
    {details = "Wait for everyone again before extinguishing the brazier."})
escort(452, 2058, "Pyrewood Ambush", nil, 12, "Horde", "Accepting starts the defense.")
uncertainEscort(87491, 271481, "Spark of Freedom", nil, 25, "Alliance", "Accepting starts an escape.")
uncertainEscort(88857, nil, "Saving a Sentinel", nil, 45, "Alliance", "Accepting starts an escape.")
uncertainEscort(93125, 254040, "Going Home", nil, 35, "Horde", "Accepting starts an escape.", {details = "Verify Gelkis reputation and current quest access for everyone; the required threshold and group invitations are unverified."})
uncertainEscort(93585, 255597, "This Light of Mine", nil, 30, "Alliance", "Accepting starts an escape.")
uncertainEscort(94556, 258048, "Jom-jom's Escape", nil, 36, "Horde", "Accepting starts an escape.")
uncertainEscort(94927, 259057, "Dunston Checks Out", 96126, 38, "Alliance", "Accepting starts an escape.")
uncertainEscort(94969, nil, "Krol'dok No More!", nil, 40, "Alliance", "Accepting starts an escape.")
uncertainEscort(96204, 248755, "The Windshaper's Wrath", 91862, 18, "Horde", "Accepting starts an escape.", {participantRoles = true, classID = 2, raceIDs = {5}})
uncertainEscort(96811, 266508, "Escaping the Shadows", 96798, 45, "Alliance", "Accepting starts an escape.")
uncertainEscort(97331, 268992, "Zimmix's Great Escape", 97329, 30, nil, "Accepting starts an escape.")
uncertainEscort(98430, 272203, "The Longwalkers", nil, 1, "Horde", "Accepting starts an escape.")
uncertainEscort(99053, 275744, "Escaping Ban'ethil", nil, 4, "Alliance", "Accepting starts an escape.")
uncertainEscort(99123, 275811, "Lost in the Shadows", nil, 4, "Horde", "Accepting starts an escape.")
uncertainEscort(99144, 275954, "Seeking Refuge", nil, 5, "Horde", "Accepting starts an escape.", {raceIDs = {2, 5}})
-- Additional escort/defense leads confirmed in the expanded source pass.
escort(1090, 4276, "Gerenzo's Orders", nil, 17, "Both", "Accepting starts the defense.")
escort(1651, 6182, "The Tome of Valor", 1650, 20, "Alliance", "Accepting starts the defense.", {participantRoles = true, classID = 2, raceIDs = {1, 3}, automatic = false, details = "Paladin defense: verify quest participants, helpers, and current event availability; helper roles are not inferred.", partyAccept = false})
escort(2969, 7956, "Freedom for All Creatures", nil, 38, "Alliance", "Accepting starts the timer.",
    {details = "Gather everyone before accepting or opening the cage; Kindal then follows."})
escort(4265, nil, "Freed from the Hive", 4135, 40, "Alliance", "Reported: the release scene ends quickly.", {automatic = false, details = "Quest is offered by pod #164954. Verify every player can participate in the release; the addon cannot warn before attacking/opening the pod.", partyAccept = false})
escort(7622, 14494, "The Balance of Light and Shadow", nil, 60, "Both", "Starts the rescue. Outside help may disrupt it.", {participantRoles = true, classID = 5, automatic = false, partyAccept = false, details = "Verify Eye of Divinity access and the special participation/interference rules. Do not assume ordinary party assistance is safe."})
uncertainEscort(91696, 244425, "Open Season", 91698, 54, nil, "Accepting sends the family out of the den.", {prerequisiteNames = {[91698] = "Barkskin Breakout"}, details = "Verify faction/reputation access and how each player joins after Barkskin Breakout; full eligibility and group invitations are unverified."})
rules.g434 = {id = "g434", questID = 434, npcID = 7766, title = "The Attack!",
    kind = "gossip", prerequisites = {}, automatic = false, requireActiveToDetect = true,
    consequence = "Starts the garden scene and fight.",
    nextStep = "One player: tell Tyrion to start.",
    details = "Accept The Attack! first. Verify Tyrion offers the start dialogue and everyone is at the correct event stage. Forever reports distinguish this from acceptance."}

rules.g2078 = {id = "g2078", questID = 2078, npcID = 6669, title = "Gyromast's Revenge",
    kind = "gossip", prerequisites = {2098}, automatic = false,
    consequence = "The robot follows, then attacks near Gelkak.",
    nextStep = "One player: use the robot's key dialogue.",
    details = "Accept Gyromast's Revenge first. Check the key and robot state; stay together for the later fight."}
rules.t4201 = {id = "t4201", questID = 4201, npcID = 9500, title = "The Love Potion",
    kind = "turnin", prerequisites = {}, automatic = false,
    consequence = "Reported: Nagmara and Rocknot leave.",
    nextStep = "Quest holders: turn in together.",
    details = "Prepare all needed hand-ins before Nagmara leaves for the door scene. Helpers do not need the quest."}
-- Questless dungeon dialogue: real NPC identities, no fabricated quest/option IDs.
local function dialogue(npcID, title, consequence, nextStep, details)
    local id = "n" .. npcID
    rules[id] = {id = id, npcID = npcID, title = title, kind = "gossip",
        prerequisites = {}, automatic = false, consequence = consequence, nextStep = nextStep, details = details}
end
dialogue(3678, "Awakening Naralex",
    "Starts the escort, ritual and enemy waves.",
    "One player: tell the Disciple to start.",
    "Verify the Fang leaders are defeated, the start dialogue is available, and everyone is present. No quest-log entry proves dungeon readiness.")
dialogue(3849, "Shadowfang courtyard: Adamant",
    "Adamant leaves to open the door.",
    "One player: ask Adamant to lead.",
    "Verify the prison encounter is finished and everyone is present. This is a dungeon escort, not a shared quest.")
dialogue(3850, "Shadowfang courtyard: Ashcrombe",
    "Ashcrombe opens the door, then leaves.",
    "One player: ask Ashcrombe to lead.",
    "Verify the prison encounter is finished and everyone is present. This is a dungeon escort, not a shared quest.")
dialogue(7604, "Bly's confrontation",
    "May start a fight. Send Weegli to the door first.",
    "One player: confront Bly.",
    "Verify the pyramid battle is over and Weegli's door task is arranged. This warning does not cover opening the prisoners' cages.")
dialogue(7607, "Weegli's demolition",
    "Weegli leaves for the door. Do this before fighting Bly.",
    "One player: send Weegli to the door.",
    "Verify the pyramid battle is finished, Weegli can act, and everyone is prepared. The addon cannot infer the door or NPC's state.")
-- Dungeon audit additions. Conversation warnings identify the NPC, not a
-- guessed option ID. Scene availability and participant roles remain Unknown.
dialogue(7998, "Grubbis: Emi's demolition",
    "Starts enemy waves and the Grubbis fight.",
    "One player: tell Emi to start.",
    "Verify everyone is present and prepared for the demolition. This is a dialogue event, not a quest acceptance.")
dialogue(9039, "Challenge the Seven",
    "Starts the fight. Finish Gloom'rel's training first.",
    "One player: challenge Doom'rel.",
    "Verify miners have finished with Gloom'rel and the party is prepared. Other members do not need Mining or a training quest.")
dialogue(9543, "Ribbly's confrontation",
    "Starts a fight with Ribbly and his cronies.",
    "One player: confront Ribbly.",
    "Verify the intended bar route, positioning, and combat preparation. Ribbly's quest is not required of every helper.")
dialogue(9500, "Nagmara's repeat door scene",
    "Nagmara and Rocknot leave. Finish bar business first.",
    "One player: send Nagmara to Rocknot.",
    "Verify the repeat dialogue is available and everyone has finished needed bar business. It normally follows The Love Potion.")
rules.n9500.afterQuestID = 4201
dialogue(9022, "Windsor: release Dughal",
    "Windsor's escort resumes.",
    "One player: release Dughal.\nEveryone: follow Windsor.",
    "Verify Windsor is waiting at this rescue stage and everyone has caught up. Helpers need not hold Jail Break.")
dialogue(9679, "Windsor: release Tobias",
    "Windsor's escort resumes.",
    "One player: release Tobias.\nEveryone: follow Windsor.",
    "Verify Windsor is waiting at this rescue stage and everyone has caught up. Other Windsor dialogue stops are not separately detected.")
dialogue(14354, "Pusillin's chase",
    "Pusillin runs. His final dialogue starts a fight.",
    "One player: talk to Pusillin.\nEveryone: follow together.",
    "Verify the current chase stop and the route. Later conversations at this same NPC need a fresh /zkir retry for renewed coordination.")
for _, id in ipairs({11491, 14241}) do
    dialogue(id, "Ironbark's door event",
        "Ironbark opens the door, then leaves.",
        "One player: ask Ironbark to open the door.",
        "Verify Zevrim is defeated, Ironbark offers the door dialogue, and everyone is present. Old and Redeemed forms have different NPC IDs.")
end
dialogue(14325, "Kromcrush's diversion",
    "Kromcrush leaves his post. Check the Tribute route first.",
    "Disguised player: divert Kromcrush.",
    "Verify the actor's ogre disguise and the intended route. His post-Tribute conversation is different; a conversation warning alone does not identify the option.")
dialogue(248765, "Blackmaw: Unbound Spirit",
    "Starts enemy waves and totems.",
    "One player: start Bramblesnap's ritual.",
    "Verify the dungeon Elder offers the start dialogue and the party is prepared. The outdoor NPC with the same name is not this event.")
dialogue(246704, "Dalaran: Fel Ancient barriers",
    "Opens the way to Fel Ancient.",
    "One player: ask Grindle to remove the barriers.",
    "Verify the current barrier option and party preparation. Opening access does not prove combat starts immediately; no quest requirement is inferred.")

local function turnin(id, npcID, title, consequence, nextStep, details, finishTogether)
    local key = "t" .. id
    rules[key] = {id = key, questID = id, npcID = npcID, title = title, kind = "turnin",
        prerequisites = {}, automatic = finishTogether == true, finishTogether = finishTogether,
        consequence = consequence, nextStep = nextStep, details = details}
end
turnin(4295, 9503, "Rocknot's Ale",
    "Repeated hand-ins start a fight. Finish bar business first.",
    "Ale holder: give Rocknot the agreed drinks.",
    "Verify the bar route and current event state. Previous party hand-ins are not observable; only the giver needs the ale. A new preparation needs /zkir retry.")
for _, id in ipairs({5525, 7429}) do
    turnin(id, 14338, "Free Knot!",
        "Knot leaves. Finish crafting first.",
        "One player: free Knot.",
        "Verify everyone's ogre-suit crafting is finished and the party wants Knot freed now. Only the freeing player needs the key.")
end
turnin(1193, nil, "A Broken Trap",
    "Arms Slip'kik's trap. Plan the pull first.",
    "Repairer: turn in.\nPull Slip'kik as planned.",
    "Verify the Tribute plan and trap position. Only the repairer needs the widget and oil. This warning uses the quest turn-in at object #179485.")
turnin(96335, 264770, "The Man in the Iron Chains",
    "Reported: Mason leaves. Get everyone's keys first.",
    "Quest holders: turn in together.\nThen accept More Valuable Than Gold.",
    "Verify whether a player without the quest is only helping or still needs it. Prepare all hand-ins; accept the next quest before Mason leaves. His departure and recovery behavior are reported, not guaranteed.", true)
-- Compatibility fields used by the coordination engine; copy is authored once.
for _, rule in pairs(rules) do
    rule.warning = NS.Messages.chatWarning(rule)
    rule.nextAction = NS.Messages.chatNext(rule)
end
NS.Rules = rules
