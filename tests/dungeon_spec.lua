local NS = {}
assert(loadfile("ZKIRPartyQuesting/Rules.lua"))("ZKIR", NS)
assert(loadfile("ZKIRPartyQuesting/Facts.lua"))("ZKIR", NS)
assert(loadfile("ZKIRPartyQuesting/Core.lua"))("ZKIR", NS)

local checks = 0
local function eq(actual, expected, message)
    assert(actual == expected, message .. ": " .. tostring(actual) .. " ~= " .. tostring(expected))
    checks = checks + 1
end
local function fact(ruleID, snapshot, expected, message)
    local result = NS.Evaluate(assert(NS.Rules[ruleID], "missing dungeon interaction " .. ruleID), snapshot)
    eq(result.state, expected, message)
    return result
end
local function questSnapshot(questID, active, complete, rewarded, failed)
    return {level = 60, faction = "Alliance", space = true, quests = {
        [questID] = {active = active, complete = complete, rewarded = rewarded, failed = failed}}}
end

-- These encounters start through the NPC's dialogue, without a shared quest.
-- A fabricated quest ID would block helpers or warn at the wrong interaction.
local dialogueNPCs = {7998, 9039, 9543, 9500, 9022, 9679, 14354, 11491, 14241, 14325, 248765, 246704}
for _, npcID in ipairs(dialogueNPCs) do
    local id = "n" .. npcID
    local rule = assert(NS.Rules[id], "missing researched dungeon NPC " .. npcID)
    eq(rule.kind, "gossip", id .. " warns before the dialogue selection")
    eq(rule.npcID, npcID, id .. " identifies the actual event NPC")
    eq(rule.questID, nil, id .. " does not invent a quest for helpers")
    local before = fact(id, {}, "U", id .. " cannot infer scene readiness")
    local after = fact(id, {level = 1, space = false, quests = {
        [99999] = {active = true, complete = true, failed = true}}}, "U",
        id .. " unrelated quests and capacity do not disqualify helpers")
    eq(before.signature, after.signature, id .. " unrelated changes preserve assessment")
end

-- Crafting, release and supply hand-ins have witnesses. They must not require
-- the actor's supplies or quest on every member, nor advertise group acceptance.
for _, questID in ipairs({4295, 5525, 7429, 1193}) do
    local id = "t" .. questID
    local rule = assert(NS.Rules[id], "missing dungeon hand-in " .. questID)
    eq(rule.kind, "turnin", id .. " starts on hand-in")
    eq(rule.questID, questID, id .. " uses researched quest identity")
    eq(NS.Rules["a" .. questID], nil, id .. " does not falsely warn on acceptance")
    fact(id, questSnapshot(questID, false, false, false, false), "U",
        id .. " witness without the quest remains assessable")
    fact(id, questSnapshot(questID, true, false, false, false), "U",
        id .. " another participant can perform the hand-in")
    fact(id, questSnapshot(questID, true, true, true, false), "U",
        id .. " historical completion does not certify this instance")
    fact(id, {quests = {}}, "U", id .. " unavailable quest APIs remain Unknown")
    local s = questSnapshot(questID, true, true, false, false)
    local before = fact(id, s, "U", id .. " current completed quest still needs assessment")
    s.quests[99999] = {active = true, complete = true, rewarded = true}
    local unrelated = fact(id, s, "U", id .. " unrelated quest remains irrelevant")
    eq(before.signature, unrelated.signature, id .. " unrelated update preserves confirmation")
    s.quests[questID].rewarded = true
    local relevant = fact(id, s, "U", id .. " hand-in evidence changes readiness context")
    assert(before.signature ~= relevant.signature, id .. " relevant update must invalidate old confirmation")
    checks = checks + 1
end
eq(NS.Rules.t4295.npcID, 9503, "Rocknot's ale hand-in is distinct from Nagmara")
eq(NS.Rules.n9500.npcID, NS.Rules.t4201.npcID, "Nagmara has initial reward and repeat dialogue warnings")
eq(NS.Rules.n9037, nil, "Gloom'rel's ordinary training is not Doom'rel's challenge")

-- A first Mason hand-in can make him leave: holders with unfinished objectives
-- are known blockers, while non-holders may be ordinary witnesses.
local mason = assert(NS.Rules.t96335, "Mason's departure needs its reward boundary")
eq(mason.kind, "turnin", "Mason departure is a hand-in, not acceptance")
eq(NS.Rules.a96335, nil, "Mason acceptance must not be labelled as departure")
local unfinished = questSnapshot(96335, true, false, false, false)
local result = fact("t96335", unfinished, "N", "Mason quest holder still gathering objectives")
eq(result.reason, "OBJECTIVES_INCOMPLETE", "Mason blocker explains unfinished objectives")
local prepared = questSnapshot(96335, true, true, false, false)
local ready = fact("t96335", prepared, "R", "Mason objective completion allows coordinated hand-in")
prepared.quests[96335].rewarded = true
fact("t96335", prepared, "R", "historical reward does not block a current completed hand-in")
fact("t96335", questSnapshot(96335, false, false, false, false), "U", "Mason witnesses need no quest")
fact("t96335", questSnapshot(96335, false, false, true, false), "U", "past Mason hand-in does not certify witness readiness")
fact("t96335", questSnapshot(96335, true, true, false, true), "N", "failed Mason quest remains blocked")
for _, field in ipairs({"active", "complete", "rewarded", "failed"}) do
    local unknown = questSnapshot(96335, true, true, false, false)
    unknown.quests[96335][field] = nil
    fact("t96335", unknown, "U", "missing Mason " .. field .. " evidence remains Unknown")
end
assert(result.signature ~= ready.signature, "completing Mason objectives invalidates stale confirmation")
checks = checks + 1
local stable = questSnapshot(96335, true, true, false, false)
stable.quests[54321] = {active = true, complete = false}
eq(fact("t96335", stable, "R", "other quest progress does not obstruct Mason").signature,
    ready.signature, "unrelated progress preserves Mason confirmation")

-- Public sources disagree about these minimum levels. Preserve the disputed
-- range instead of using one source to label a potentially eligible player N.
for _, entry in ipairs({{1144, 22, 23}, {2904, 20, 24}}) do
    local questID, lower, upper = entry[1], entry[2], entry[3]
    local s = questSnapshot(questID, false, false, false, false)
    s.level = lower - 1
    fact("a" .. questID, s, "N", "below both researched level limits for " .. questID)
    for level = lower, upper - 1 do
        s.level = level
        fact("a" .. questID, s, "U", "disputed minimum level " .. level .. " for " .. questID)
    end
    s.level = upper
    fact("a" .. questID, s, "R", "meets both researched level limits for " .. questID)
    s.level = nil
    fact("a" .. questID, s, "U", "missing level evidence for " .. questID)
end

-- Exercise real facts through two communicating clients. A leader's manual
-- confirmation must not conceal Mason's unfinished objectives, and completing
-- them must unlock exactly one automatic next-action announcement.
local alice, bob = "Alice-Realm", "Bob-Realm"
local roster = {{name = alice, connected = true, leader = true}, {name = bob, connected = true}}
local time, queue, chats, clients = 0, {}, {}, {}
for _, name in ipairs({alice, bob}) do
    local player = name
    clients[player] = {snapshot = questSnapshot(96335, true, player == alice, false, false)}
    clients[player].core = NS.New({me = player, boot = "1000.1", saved = {},
        now = function() return time end, wall = function() return 1000 + math.floor(time) end,
        changed = function() end,
        send = function(payload)
            queue[#queue + 1] = {sender = player, payload = payload}
            return true
        end,
        chat = function(text)
            chats[#chats + 1] = {sender = player, text = text}
            return true
        end})
    clients[player].core:setRoster(roster)
end
local function pump(seconds)
    for _ = 1, seconds * 4 do
        time = time + 0.25
        for _, client in pairs(clients) do
            if client.core.active then client.core:setFact(NS.Evaluate(mason, client.snapshot)) end
            client.core:tick()
        end
        local rounds = 0
        while #queue > 0 do
            rounds = rounds + 1
            assert(rounds < 100, "dungeon exchange must not echo indefinitely")
            local batch = queue; queue = {}
            for _, message in ipairs(batch) do
                for name, client in pairs(clients) do
                    if name ~= message.sender then client.core:receive(message.sender, message.payload) end
                end
            end
        end
    end
end
clients[bob].core:detect("t96335", "mason-instance")
pump(25)
for _, client in pairs(clients) do
    eq(client.core.active.ruleID, "t96335", "Mason reward warning synchronizes")
    eq(client.core:allReady(), false, "unfinished member prevents a proceed announcement")
end
local remoteBob
for _, row in ipairs(clients[alice].core:rows()) do
    if row.name == bob then remoteBob = row end
end
eq(assert(remoteBob, "leader must show Bob").status, "Not Ready", "leader received Bob's verified objective blocker")
eq(clients[alice].core:confirm(bob, "R"), false, "leader cannot override verified unfinished objectives")
eq(#chats, 1, "only the initial warning is sent while objectives are unfinished")
clients[bob].snapshot.quests[96335].complete = true
pump(25)
for _, client in pairs(clients) do eq(client.core:allReady(), true, "objective completion is shared automatically") end
eq(#chats, 2, "completion emits one next-action message")
for _, chat in ipairs(chats) do eq(chat.sender, alice, "the actual leader announces") end
assert(chats[2].text:find(mason.nextAction, 1, true), "announcement describes the researched next action")
clients[bob].snapshot.quests[11111] = {active = true, complete = true}
pump(10)
eq(#chats, 2, "unrelated updates do not duplicate the departure announcement")

print("dungeon: " .. checks .. " trigger, evidence, conflict and multiplayer checks")
