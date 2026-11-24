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
        exclusive = options.exclusive, repeatable = options.repeatable,
        classID = options.classID, raceIDs = options.raceIDs, participantRoles = options.participantRoles,
        warning = "WAIT for everyone before accepting " .. title .. ". " .. consequence,
        nextAction = options.nextAction or (options.partyAccept ~= false and
            ("Everyone ready for " .. title .. " — one player may accept; others join when offered.") or
            ("Everyone confirmed prepared for " .. title .. " — use the agreed start; check each player's quest log."))}
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
escort(155, 467, "The Defias Brotherhood", 142, 14, "Alliance", "The Traitor starts moving; finish prerequisite hand-ins first.")
escort(648, 7784, "Rescue OOX-17/TN!", 351, 43, "Both", "The escort starts immediately; hand in Find OOX-17/TN! first.")
escort(731, 2917, "The Absent Minded Prospector", 729, 15, "Alliance", "Remtravel starts his escort; hand in step #729 first.")
escort(836, 7806, "Rescue OOX-09/HL!", 485, 43, "Both", "The escort starts immediately; hand in Find OOX-09/HL! first.")
escort(945, 3584, "Therylune's Escape", nil, 10, "Alliance", "Therylune starts moving; gather everyone first.")
escort(2767, 7807, "Rescue OOX-22/FE!", 2766, 40, "Both", "The escort starts immediately; hand in Find OOX-22/FE! first.")
escort(4245, 9623, "Chasing A-Me 01", 4244, 48, "Both", "A-Me starts her escort; everyone must hand in the Mithril Casing repair step #4244 first.")
escort(5321, 11218, "The Sleeper Has Awakened", nil, 17, "Alliance", "Kerlonian starts moving; gather everyone and check his supplies first.")
escort(6482, 12818, "Freedom to Ruul", nil, 19, "Horde", "Ruul starts his escape; gather everyone first.")
escort(7046, 13716, "The Scepter of Celebras", 7044, 41, "Both", "The long ritual starts; everyone must hand in Legends of Maraudon first.")
-- Expanded acceptance catalogue; see research/ESCORT_COVERAGE.md for sources and gaps.
escort(219, 349, "Missing In Action", nil, 19, "Alliance", "Corporal Keeshan's escort begins; gather everyone first.")
escort(309, 1379, "Protecting the Shipment", 454, 10, "Alliance", "Miran's escort begins; hand in #454 first.")
escort(435, 1978, "Escorting Erland", nil, 10, "Horde", "Erland's escort begins; gather everyone first.")
escort(660, 2713, "Hints of a New Plague?", 657, 30, "Alliance", "Kinelory's escort begins; hand in #657 first.")
escort(665, 2768, "Sunken Treasure", 663, 35, "Both", "Professor Phizzlethorpe's escort begins; hand in #663 first.")
escort(667, 2610, "Death From Below", 670, 35, "Both", "Shakes O'Breen's defense event begins; hand in #670 first.")
escort(863, 3439, "The Escape", 858, 13, "Both", "Wizzlecrank's escort begins; hand in #858 first.")
escort(898, 3465, "Free From the Hold", nil, 13, "Horde", "Gilthares's escort begins; gather everyone first.")
escort(938, 3568, "Mist", nil, 7, "Alliance", "Mist's escort begins; gather everyone first.")
escort(976, 4484, "Supplies to Auberdine", 973, 19, "Alliance", "Feero's escort begins; hand in #973 first.")
escort(994, 3692, "Escape Through Force", 993, 10, "Alliance", "Volcor's escort begins; hand in #993 first.", {exclusive = {995}})
escort(995, 3692, "Escape Through Stealth", 993, 10, "Alliance", "Volcor's escort begins; hand in #993 first.", {exclusive = {994}})
escort(1144, 4508, "Willix the Importer", nil, 23, "Both", "Willix's escort begins; gather everyone first.",
    {alternativeMinLevel = 22, details = "Sources disagree on minimum level (22 or 23). Verify acceptance access for a level-22 player."})
escort(1222, 4880, "Stinky's Escape", nil, 30, "Alliance", "Stinky Ignatz's escort begins; gather everyone first.")
escort(1249, 4963, "The Missing Diplomat", 1248, 28, "Alliance", "The confrontation begins; hand in #1248 first.")
escort(1270, 4880, "Stinky's Escape", nil, 30, "Horde", "Stinky Ignatz's escort begins; gather everyone first.")
escort(1273, 4983, "Questioning Reethe", 1269, 30, "Horde", "Ogron's escort begins; hand in #1269 first.")
escort(1324, 4966, "The Missing Diplomat", 1266, 28, "Alliance", "The confrontation begins; hand in #1266 first.")
escort(1393, 5391, "Galen's Escape", nil, 30, "Both", "Galen's escort begins; gather everyone first.")
escort(1440, 5644, "Return to Vahlarriel", 1439, 30, "Alliance", "Dalinda's escort begins; hand in #1439 first.")
escort(1560, 5955, "Tooga's Quest", nil, 40, "Both", "Tooga's escort begins; gather everyone first.")
escort(2742, 7780, "Rin'ji is Trapped!", nil, 42, "Horde", "Rin'ji's escort begins; gather everyone first.")
escort(2845, 7774, "Wandering Shay", 2844, 44, "Alliance", "Shay's escort begins; hand in #2844 first.")
escort(2904, 7850, "A Fine Mess", nil, 24, "Both", "Kernobee's escort begins; gather everyone first.",
    {alternativeMinLevel = 20, details = "Sources disagree on minimum level (20 or 24). Verify acceptance access for players at levels 20-23."})
escort(3367, 8284, "Suntara Stones", nil, 40, "Alliance", "Dorius's escort begins; gather everyone first.")
escort(3382, 8380, "A Crew Under Fire", nil, 48, "Both", "Captain Vanessa Beltis's defense event begins; gather everyone first.", {repeatable = true, automatic = false, details = "Repeatable defense: verify the current attack and that everyone can join this attempt."})
escort(3525, 8516, "Extinguishing the Idol", 3523, 32, "Both", "Belnistrasz starts his escort and ritual; everyone must hand in #3523 first.")
escort(3982, 9020, "What Is Going On?", 3981, 48, "Horde", "Gor'shak's defense event begins; hand in #3981 first.")
escort(4121, 9520, "Precarious Predicament", 4122, 52, "Horde", "Grark's escort begins; hand in #4122 first.")
escort(4261, 9598, "Ancient Spirit", 4442, 49, "Alliance", "Arei's escort begins; hand in #4442 first.")
escort(4322, 9023, "Jail Break!", 4282, 50, "Alliance", "Windsor starts his escape; hand in #4282 first and regroup at his later dialogue stops.")
escort(4491, 9999, "A Little Help From My Friends", 4492, 50, "Both", "Ringo starts following; finish hand-ins and check the supplies needed when he faints.")
escort(4770, 10427, "Homeward Bound", nil, 25, "Horde", "Pao'ka's escort begins; gather everyone first.")
escort(4901, 10300, "Guardians of the Altar", 979, 52, "Alliance", "Ranshalla starts moving; gather everyone, then coordinate her later torch and altar stops.")
escort(4904, 10646, "Free at Last", nil, 25, "Horde", "Lakota's escort begins; gather everyone first.")
escort(4966, 10638, "Protect Kanati Greycloud", 4881, 23, "Horde", "Kanati Greycloud's defense event begins; hand in #4881 first.")
escort(5203, 11016, "Rescue From Jaedenar", 5202, 49, "Both", "Arko'narin's escort begins; hand in #5202 first.")
escort(5713, 11711, "One Shot. One Kill.", nil, 10, "Alliance", "Sentinel Aynasha's defense event begins; gather everyone first.")
escort(5821, 11625, "Bodyguard for Hire", nil, 30, "Both", "The caravan enters an ambush leg; gather everyone at its quest stop.")
escort(5943, 11626, "Gizelton Caravan", nil, 32, "Both", "The caravan enters the Mannoroc ambush leg; gather everyone at its quest stop.")
escort(5944, 1842, "In Dreams", 5862, 52, "Both", "Taelan's escort begins; hand in #5862 first.")
escort(6132, 12277, "Get Me Out of Here!", nil, 34, "Both", "Melizza's escort begins; gather everyone first.")
escort(6403, 12580, "The Great Masquerade", 6402, 50, "Alliance", "Windsor begins his march; gather everyone and regroup before the later keep dialogue.", {exclusive = {99435}})
escort(6523, 11856, "Protect Kaya", nil, 12, "Horde", "Kaya's escort begins; gather everyone first.")
escort(6544, 12858, "Torek's Assault", nil, 20, "Horde", "Torek's escort begins; gather everyone first.")
escort(6641, 12717, "Vorsha the Lasher", nil, 20, "Horde", "Muglash starts moving; gather everyone and wait again before extinguishing the brazier.")
escort(452, 2058, "Pyrewood Ambush", nil, 12, "Horde", "Deathstalker Faerleia's defense event begins; gather everyone first.")
uncertainEscort(87491, 271481, "Spark of Freedom", nil, 25, "Alliance", "The captive fire elemental starts an escape; verify everyone can join before starting.")
uncertainEscort(88857, nil, "Saving a Sentinel", nil, 45, "Alliance", "Keldara starts an escape; verify everyone can join before starting.")
uncertainEscort(93125, 254040, "Going Home", nil, 35, "Horde", "Rokren starts an escape; verify everyone can join before starting.", {details = "Verify Gelkis reputation and current quest access for everyone; the required threshold and group invitations are unverified."})
uncertainEscort(93585, 255597, "This Light of Mine", nil, 30, "Alliance", "Father Tuttle starts an escape; verify everyone can join before starting.")
uncertainEscort(94556, 258048, "Jom-jom's Escape", nil, 36, "Horde", "Jom-jom starts an escape; verify everyone can join before starting.")
uncertainEscort(94927, 259057, "Dunston Checks Out", 96126, 38, "Alliance", "Dunston starts an escape; verify everyone can join before starting.")
uncertainEscort(94969, nil, "Krol'dok No More!", nil, 40, "Alliance", "Marcus starts an escape; verify everyone can join before starting.")
uncertainEscort(96204, 248755, "The Windshaper's Wrath", 91862, 18, "Horde", "Lumina starts an escape; verify everyone can join before starting.", {participantRoles = true, classID = 2, raceIDs = {5}})
uncertainEscort(96811, 266508, "Escaping the Shadows", 96798, 45, "Alliance", "Sergeant Danneth starts an escape; verify everyone can join before starting.")
uncertainEscort(97331, 268992, "Zimmix's Great Escape", 97329, 30, nil, "Zimmix starts an escape; verify everyone can join before starting.")
uncertainEscort(98430, 272203, "The Longwalkers", nil, 1, "Horde", "Perith starts an escape; verify everyone can join before starting.")
uncertainEscort(99053, 275744, "Escaping Ban'ethil", nil, 4, "Alliance", "Lynessa starts an escape; verify everyone can join before starting.")
uncertainEscort(99123, 275811, "Lost in the Shadows", nil, 4, "Horde", "Pal'juh starts an escape; verify everyone can join before starting.")
uncertainEscort(99144, 275954, "Seeking Refuge", nil, 5, "Horde", "Bareth starts an escape; verify everyone can join before starting.", {raceIDs = {2, 5}})
-- Additional escort/defense leads confirmed in the expanded source pass.
escort(1090, 4276, "Gerenzo's Orders", nil, 17, "Both", "Piznik starts mining and enemies attack; gather everyone before the defense.")
escort(1651, 6182, "The Tome of Valor", 1650, 20, "Alliance", "Daphne moves to defend the house; coordinate quest participants and helpers first.", {participantRoles = true, classID = 2, raceIDs = {1, 3}, automatic = false, details = "Paladin defense: verify quest participants, helpers, and current event availability; helper roles are not inferred.", partyAccept = false})
escort(2969, 7956, "Freedom for All Creatures", nil, 38, "Alliance", "Kindal follows and the timer starts; gather everyone before accepting or opening the cage.")
escort(4265, nil, "Freed from the Hive", 4135, 40, "Alliance", "Reported: Raschal's release scene ends quickly; coordinate everyone before accepting.", {automatic = false, details = "Quest is offered by pod #164954. Verify every player can participate in the release; the addon cannot warn before attacking/opening the pod.", partyAccept = false})
escort(7622, 14494, "The Balance of Light and Shadow", nil, 60, "Both", "The peasant rescue starts; coordinate participants first. Outside help may disrupt it.", {participantRoles = true, classID = 5, automatic = false, partyAccept = false, details = "Verify Eye of Divinity access and the special participation/interference rules. Do not assume ordinary party assistance is safe."})
uncertainEscort(91696, 244425, "Open Season", 91698, 54, nil, "The Barkskin family leaves the den; everyone must hand in Barkskin Breakout #91698 first.", {details = "Verify faction/reputation access and how each player joins after Barkskin Breakout; full eligibility and group invitations are unverified."})
rules.g434 = {id = "g434", questID = 434, npcID = 7766, title = "The Attack!",
    kind = "gossip", prerequisites = {}, automatic = false, requireActiveToDetect = true,
    warning = "WAIT for everyone before Tyrion's start dialogue. Have The Attack! accepted first; this starts the garden scene and confrontation.",
    nextAction = "Everyone confirmed prepared — one player may choose Tyrion's start dialogue; stay together for the confrontation.",
    details = "Verify Tyrion offers the start dialogue and everyone is at the correct event stage. Forever reports distinguish this from acceptance."}

rules.g2078 = {id = "g2078", questID = 2078, npcID = 6669, title = "Gyromast's Revenge",
    kind = "gossip", prerequisites = {2098}, automatic = false,
    warning = "WAIT for everyone before the robot's key dialogue. Have Gyromast's Revenge accepted; the robot follows, then turns hostile near Gelkak.",
    nextAction = "Everyone confirmed prepared — one player may use the robot's key dialogue; stay together for the later fight."}
rules.t4201 = {id = "t4201", questID = 4201, npcID = 9500, title = "The Love Potion",
    kind = "turnin", prerequisites = {}, automatic = false,
    warning = "WAIT for everyone before handing in The Love Potion. Reported behavior: Nagmara and Rocknot leave for the door scene; finish coordinating hand-ins first.",
    nextAction = "Everyone confirmed prepared — coordinate the needed hand-ins now, before Nagmara leaves."}
-- Questless dungeon dialogue: real NPC identities, no fabricated quest/option IDs.
local function dialogue(npcID, title, warning, nextAction, details)
    local id = "n" .. npcID
    rules[id] = {id = id, npcID = npcID, title = title, kind = "gossip",
        prerequisites = {}, automatic = false, warning = warning, nextAction = nextAction, details = details}
end
dialogue(3678, "Awakening Naralex",
    "WAIT for everyone before telling the Disciple to begin. His escort leads into the Naralex ritual and enemy waves.",
    "Everyone confirmed prepared — one player may start the Disciple's escort; stay together for the ritual.",
    "Verify the Fang leaders are defeated, the start dialogue is available, and everyone is present. No quest-log entry proves dungeon readiness.")
dialogue(3849, "Shadowfang courtyard: Adamant",
    "WAIT for everyone before asking Adamant to lead the way. He leaves the cell to open the courtyard door.",
    "Everyone confirmed prepared — one player may ask Adamant to lead; follow him to the courtyard door.",
    "Verify the prison encounter is finished and everyone is present. This is a dungeon escort, not a shared quest.")
dialogue(3850, "Shadowfang courtyard: Ashcrombe",
    "WAIT for everyone before asking Ashcrombe to lead the way. He opens the courtyard door and then leaves.",
    "Everyone confirmed prepared — one player may ask Ashcrombe to lead; follow him to the courtyard door.",
    "Verify the prison encounter is finished and everyone is present. This is a dungeon escort, not a shared quest.")
dialogue(7604, "Bly's confrontation",
    "WAIT for everyone before confronting Bly. His dialogue can turn the rescued prisoners hostile; coordinate Weegli's door demolition first.",
    "Everyone confirmed prepared — after arranging the door demolition, one player may confront Bly; prepare for combat.",
    "Verify the pyramid battle is over and Weegli's door task is arranged. This warning does not cover opening the prisoners' cages.")
dialogue(7607, "Weegli's demolition",
    "WAIT for everyone before sending Weegli to the door. He leaves to demolish it; coordinate this before confronting Bly.",
    "Everyone confirmed prepared — one player may send Weegli to demolish the door; keep him safe on the way.",
    "Verify the pyramid battle is finished, Weegli can act, and everyone is prepared. The addon cannot infer the door or NPC's state.")
-- Dungeon audit additions. Conversation warnings identify the NPC, not a
-- guessed option ID. Scene availability and participant roles remain Unknown.
dialogue(7998, "Grubbis: Emi's demolition",
    "WAIT for everyone before telling Emi to begin. Her tunnel demolition starts waves of troggs and the Grubbis fight.",
    "Everyone confirmed prepared — one player may tell Emi to begin; protect her through the tunnel waves.",
    "Verify everyone is present and prepared for the demolition. This is a dialogue event, not a quest acceptance.")
dialogue(9039, "Challenge the Seven",
    "WAIT for everyone before challenging Doom'rel. The Seven attack; finish any Gloom'rel mining training first.",
    "Everyone confirmed prepared — after all needed training, one player may challenge Doom'rel; prepare for the Seven.",
    "Verify miners have finished with Gloom'rel and the party is prepared. Other members do not need Mining or a training quest.")
dialogue(9543, "Ribbly's confrontation",
    "WAIT for everyone before confronting Ribbly. His dialogue starts a fight with him and his cronies in the bar.",
    "Everyone confirmed prepared — one player may confront Ribbly; prepare for his cronies and nearby patrons.",
    "Verify the intended bar route, positioning, and combat preparation. Ribbly's quest is not required of every helper.")
dialogue(9500, "Nagmara's repeat door scene",
    "WAIT for everyone before sending Nagmara to Rocknot. The pair leave for the door scene; agree on the bar route first.",
    "Everyone confirmed prepared — one player may ask Nagmara to visit Rocknot; follow the agreed door route.",
    "Verify the repeat dialogue is available and everyone has finished needed bar business. It normally follows The Love Potion.")
rules.n9500.afterQuestID = 4201
dialogue(9022, "Windsor: release Dughal",
    "WAIT for everyone before releasing Dughal. This dialogue resumes Windsor's Jail Break escort.",
    "Everyone confirmed prepared — one player may release Dughal; stay with Windsor as the escort resumes.",
    "Verify Windsor is waiting at this rescue stage and everyone has caught up. Helpers need not hold Jail Break.")
dialogue(9679, "Windsor: release Tobias",
    "WAIT for everyone before releasing Tobias. This dialogue resumes Windsor's Jail Break escort.",
    "Everyone confirmed prepared — one player may release Tobias; stay with Windsor as the escort resumes.",
    "Verify Windsor is waiting at this rescue stage and everyone has caught up. Other Windsor dialogue stops are not separately detected.")
dialogue(14354, "Pusillin's chase",
    "WAIT for everyone before advancing Pusillin's dialogue. He runs through Dire Maul; the final conversation starts a fight.",
    "Everyone confirmed prepared — one player may advance Pusillin's dialogue; follow together and regroup before the final fight.",
    "Verify the current chase stop and the route. Later conversations at this same NPC need a fresh /zkir retry for renewed coordination.")
for _, id in ipairs({11491, 14241}) do
    dialogue(id, "Ironbark's door event",
        "WAIT for everyone before asking Ironbark to open the door. He moves to break the barrier and then leaves the encounter.",
        "Everyone confirmed prepared — one player may ask Ironbark to open the door; gather before entering the next area.",
        "Verify Zevrim is defeated, Ironbark offers the door dialogue, and everyone is present. Old and Redeemed forms have different NPC IDs.")
end
dialogue(14325, "Kromcrush's diversion",
    "WAIT for everyone before using the ogre-disguise diversion on Kromcrush. He leaves his post; coordinate the Tribute route first.",
    "Everyone confirmed prepared — the disguised player may divert Kromcrush; follow the agreed Tribute route.",
    "Verify the actor's ogre disguise and the intended route. His post-Tribute conversation is different; a conversation warning alone does not identify the option.")
dialogue(248765, "Blackmaw: Unbound Spirit",
    "WAIT for everyone before starting Elder Bramblesnap's ritual. The Unbound Spirit encounter brings enemy waves and totems.",
    "Everyone confirmed prepared — one player may start Bramblesnap's ritual; protect him and handle the totems together.",
    "Verify the dungeon Elder offers the start dialogue and the party is prepared. The outdoor NPC with the same name is not this event.")
dialogue(246704, "Dalaran: Fel Ancient barriers",
    "WAIT for everyone before asking Grindle Firespark to remove the barriers. This opens access to the Fel Ancient encounter.",
    "Everyone confirmed prepared — one player may ask Grindle to remove the barriers; prepare to engage Fel Ancient together.",
    "Verify the current barrier option and party preparation. Opening access does not prove combat starts immediately; no quest requirement is inferred.")

local function turnin(id, npcID, title, warning, nextAction, details, finishTogether)
    local key = "t" .. id
    rules[key] = {id = key, questID = id, npcID = npcID, title = title, kind = "turnin",
        prerequisites = {}, automatic = finishTogether == true, finishTogether = finishTogether,
        warning = warning, nextAction = nextAction, details = details}
end
turnin(4295, 9503, "Rocknot's Ale",
    "WAIT for everyone before giving Rocknot ale. Repeated hand-ins start his rampage and the Phalanx door fight; finish bar business first.",
    "Everyone confirmed prepared — the designated player may make the agreed ale hand-ins; prepare for Rocknot and Phalanx.",
    "Verify the bar route and current event state. Previous party hand-ins are not observable; only the giver needs the ale. A new preparation needs /zkir retry.")
for _, id in ipairs({5525, 7429}) do
    turnin(id, 14338, "Free Knot!",
        "WAIT for everyone before handing in Free Knot! Knot leaves; finish all needed ogre-suit crafting before freeing him.",
        "Everyone confirmed prepared — after all needed crafting, one player may give Knot the shackle key.",
        "Verify everyone's ogre-suit crafting is finished and the party wants Knot freed now. Only the freeing player needs the key.")
end
turnin(1193, nil, "A Broken Trap",
    "WAIT for everyone before repairing the Broken Trap. The turn-in arms it for Slip'kik; coordinate the Tribute route and pull first.",
    "Everyone confirmed prepared — the designated player may repair the trap; coordinate Slip'kik's approach.",
    "Verify the Tribute plan and trap position. Only the repairer needs the widget and oil. This warning uses the quest turn-in at object #179485.")
turnin(96335, 264770, "The Man in the Iron Chains",
    "WAIT for everyone before handing in The Man in the Iron Chains. Reported: Mason leaves after turn-in; finish key looting and prepare all hand-ins first.",
    "Everyone ready — coordinate the hand-ins together, then take More Valuable Than Gold before Mason leaves.",
    "Verify whether a player without the quest is only helping or still needs it. Mason's departure and recovery behavior are reported, not guaranteed.", true)
NS.Rules = rules
