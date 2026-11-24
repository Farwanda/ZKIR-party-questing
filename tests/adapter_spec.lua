-- Runs the real TOC files with mocked public APIs and UI objects, not a game client.
local client = assert(loadfile("tests/client.lua"))()
local passed = 0
local function test(name, fn) fn(); passed = passed + 1 end
test("pre-accept synchronous window / normal controls untouched", function()
    local c = client(); c.event("QUEST_DETAIL")
    assert(c.ns.engine.active.ruleID == "a7046")
    local window
    for _, f in ipairs(c.frames) do if f.name == "ZKIRPartyQuestingWindow" then window = f end end
    assert(window and window.shown, "window must open during pre-action event")
    c.advance(10); assert(c.ns.engine:allReady())
    c.event("QUEST_ACCEPTED", 7046, 123) -- Forever first argument, not Classic second
    assert(c.ns.engine.active.started and not c.ns.engine:allReady())
    assert(#c.messages == 0, "solo must not emit party messages")
end)
test("turn-in progress and reward-stage detection / distinct action", function()
    local c = client(); c.setQuest(4201); c.event("QUEST_PROGRESS")
    assert(c.ns.engine.active.ruleID == "t4201")
    local key = c.ns.engine.active.key
    c.event("QUEST_COMPLETE"); assert(c.ns.engine.active.key == key)
    assert(c.ns.engine:rows()[1].status == "Unknown")
    c.event("QUEST_TURNED_IN", 4201); assert(c.ns.engine.active.started)
end)
test("A-Me escort warns before acceptance and tracks the repair hand-in", function()
    local c = client({guid = "Creature-0-1-1-1-9623-0001"})
    c.state[4244] = {active = true, complete = true, rewarded = false}
    c.setQuest(4245); c.event("QUEST_DETAIL")
    assert(c.ns.engine.active and c.ns.engine.active.ruleID == "a4245", "missing A-Me escort rule")
    local window
    for _, f in ipairs(c.frames) do if f.name == "ZKIRPartyQuestingWindow" then window = f end end
    assert(window and window.shown and not c.ns.engine.active.started)
    c.advance(10); assert(c.ns.engine:rows()[1].status == "Not Ready")
    c.state[4244] = {active = false, rewarded = true}
    c.event("QUEST_TURNED_IN", 4244); c.event("QUEST_LOG_UPDATE"); c.advance(10)
    assert(c.ns.engine:allReady(), "repair hand-in should make first acceptance ready")
    assert(not c.ns.engine.active.started, "repair hand-in is not escort acceptance")
    c.event("QUEST_ACCEPTED", 4245)
    assert(c.ns.engine.active.started and not c.ns.engine:allReady())
end)
test("A-Me identical-title steps stay distinct / gossip offer warns early", function()
    local c = client({guid = "Creature-0-1-1-1-9623-0001"})
    for _, id in ipairs({4243, 4244}) do
        c.setQuest(id); c.event("QUEST_DETAIL"); c.event("QUEST_PROGRESS"); c.event("QUEST_COMPLETE")
        assert(not c.ns.engine.active, "earlier A-Me steps must not start escort coordination")
    end
    c.env.C_GossipInfo.GetAvailableQuests = function() return {{questID = 4244}} end
    c.event("GOSSIP_SHOW"); assert(not c.ns.engine.active)
    c.env.C_GossipInfo.GetAvailableQuests = function() return {{questID = 4245}} end
    c.event("GOSSIP_SHOW"); assert(c.ns.engine.active and c.ns.engine.active.ruleID == "a4245")
end)
test("dialogue warns at NPC conversation / posthook retires readiness", function()
    local c = client({guid = "Creature-0-1-1-1-6669-0001"}); c.event("GOSSIP_SHOW")
    assert(c.ns.engine.active.ruleID == "g2078")
    c.hooks.SelectOption(123); assert(c.ns.engine.active.started)
end)
test("restricted NPC identity cannot fabricate dialogue detection", function()
    local c = client({guid = {secret = true}}); c.event("GOSSIP_SHOW")
    assert(not c.ns.engine.active)
    c.event("QUEST_DETAIL"); assert(c.ns.engine.active.ruleID == "a7046")
end)
test("missing/secret quest facts are unknown / no legacy assumptions", function()
    local c = client({secretHistory = true}); c.event("QUEST_DETAIL"); c.advance(6)
    assert(c.ns.engine:rows()[1].status == "Unknown")
    c = client(); c.env.C_QuestLog.IsOnQuest = nil; c.event("QUEST_DETAIL"); c.advance(6)
    assert(c.ns.engine:rows()[1].status == "Unknown")
    c = client(); c.env.UnitIsConnected = nil; c.event("GROUP_ROSTER_UPDATE"); c.event("QUEST_DETAIL"); c.advance(6)
    assert(c.ns.engine:rows()[1].status == "Unknown", "missing connection API is not proof of disconnection")
end)
test("message registration enums / send failures / lockdown", function()
    local c = client({party = true, registration = 1}); c.event("QUEST_DETAIL")
    assert(#c.messages > 0 and c.ns.engine.healthy)
    for _, opt in ipairs({{party = true, registration = 2}, {party = true, sendResult = 11},
        {party = true, locked = true}, {party = true, nilSend = true}}) do
        c = client(opt); c.event("QUEST_DETAIL"); c.advance(20)
        assert(not c.ns.engine:allReady() and not c.ns.engine.healthy)
        assert(#c.messages <= 1, "unavailable messaging must not spam")
    end
end)
test("group invitation uses third argument / no automatic acceptance", function()
    local c = client(); c.event("QUEST_DETAIL")
    c.event("QUEST_ACCEPT_CONFIRM", "Bob", "Untrusted title", 7046)
    assert(c.ns.engine.active.started and c.ns.engine.notice:find("invitation"))
end)
test("expanded acceptance catalogue opens before any action", function()
    local catalogue = client().ns.Rules
    for _, rule in pairs(catalogue) do
        if rule.kind == "accept" then
            local c = client(); c.setQuest(rule.questID); c.event("QUEST_DETAIL")
            assert(c.ns.engine.active and c.ns.engine.active.ruleID == rule.id, rule.id)
            assert(not c.ns.engine.active.started)
            c.advance(6)
        end
    end
end)
test("The Attack is a dialogue start on Forever, not an acceptance trigger", function()
    local c = client({guid = "Creature-0-1-1-1-7766-0001"})
    c.setQuest(434); c.event("QUEST_DETAIL"); c.event("GOSSIP_SHOW")
    assert(not c.ns.engine.active)
    c.state[434] = {active = true, complete = false, rewarded = false}
    c.event("QUEST_ACCEPTED", 434); assert(not c.ns.engine.active)
    c.event("GOSSIP_SHOW"); assert(c.ns.engine.active.ruleID == "g434")
    c.advance(6); assert(c.ns.engine:rows()[1].status == "Unknown")
    c.hooks.SelectOption(123); assert(c.ns.engine.active.started)
end)
test("unavailable quest state does not suppress a known Tyrion warning", function()
    local c = client({guid = "Creature-0-1-1-1-7766-0001"})
    c.env.C_QuestLog.IsOnQuest = nil
    c.event("GOSSIP_SHOW"); c.advance(6)
    assert(c.ns.engine.active.ruleID == "g434" and c.ns.engine:rows()[1].status == "Unknown")
end)
test("questless dungeon dialogues do not query a fabricated quest ID", function()
    for _, npc in ipairs({3678, 3849, 3850, 7604, 7607}) do
        local c = client({guid = "Creature-0-1-1-1-" .. npc .. "-0001"})
        c.env.C_QuestLog.IsQuestFlaggedCompleted = function() error("no quest lookup expected") end
        c.event("GOSSIP_SHOW"); c.advance(6)
        assert(c.ns.engine.active.ruleID == "n" .. npc)
        assert(c.ns.engine:rows()[1].status == "Unknown" and not c.ns.engine:allReady())
        c.hooks.SelectOption(123); assert(c.ns.engine.active.started)
    end
end)
test("alternative offers wait for quest choice / exclusive facts update", function()
    local c = client({guid = "Creature-0-1-1-1-3692-0001"})
    c.state[993] = {rewarded = true}
    c.env.C_GossipInfo.GetAvailableQuests = function() return {{questID = 994}, {questID = 995}} end
    c.event("GOSSIP_SHOW"); assert(not c.ns.engine.active)
    c.setQuest(994); c.event("QUEST_DETAIL"); c.advance(6)
    assert(c.ns.engine.active.ruleID == "a994" and c.ns.engine:allReady())
    c.state[995] = {active = true, rewarded = false}
    c.event("QUEST_LOG_UPDATE"); assert(c.ns.engine:rows()[1].status == "Not Ready")
end)
test("class-event helpers are unknown / missing race API is unknown", function()
    local c = client(); c.setQuest(1651); c.event("QUEST_DETAIL"); c.advance(6)
    assert(c.ns.engine:rows()[1].status == "Unknown", "warrior helper is not a verified quest blocker")
    c = client(); c.env.UnitFactionGroup = function() return "Horde" end
    c.env.UnitRace = nil; c.setQuest(99144); c.event("QUEST_DETAIL"); c.advance(6)
    assert(c.ns.engine:rows()[1].status == "Unknown")
    c.env.UnitRace = function() return "Tauren", "Tauren", 6 end
    c.event("QUEST_LOG_UPDATE"); assert(c.ns.engine:rows()[1].status == "Not Ready")
end)
test("dungeon dialogue warnings precede selection and retire safely", function()
    for _, npc in ipairs({7998, 9039, 9543, 9500, 9022, 9679, 14354, 11491, 14241, 14325, 248765, 246704}) do
        local c = client({guid = "Creature-0-1-1-1-" .. npc .. "-0001"})
        c.state[4201].rewarded = true
        c.event("GOSSIP_SHOW"); c.advance(6)
        assert(c.ns.engine.active.ruleID == "n" .. npc and not c.ns.engine.active.started)
        assert(c.ns.engine:rows()[1].status == "Unknown")
        c.hooks.SelectOption(123)
        local key = c.ns.engine.active.key
        c.event("GOSSIP_SHOW"); c.event("GOSSIP_SHOW")
        assert(c.ns.engine.active.key == key and c.ns.engine.active.started)
        assert(not c.ns.engine:allReady(), "later/stale menus cannot revive old preparation")
    end
    local c = client({guid = "Creature-0-1-1-1-235906-0001"})
    c.event("GOSSIP_SHOW"); assert(not c.ns.engine.active, "outdoor Bramblesnap is a different NPC")
end)
test("Nagmara repeat dialogue respects known prior completion", function()
    local c = client({guid = "Creature-0-1-1-1-9500-0001"})
    c.event("GOSSIP_SHOW"); assert(not c.ns.engine.active)
    c.env.C_QuestLog.IsQuestFlaggedCompleted = nil
    c.event("GOSSIP_SHOW"); assert(c.ns.engine.active.ruleID == "n9500")
end)
test("Nagmara history resolution invalidates confirmation without blocking helpers", function()
    local c = client({guid = "Creature-0-1-1-1-9500-0001"})
    local history = c.env.C_QuestLog.IsQuestFlaggedCompleted
    c.env.C_QuestLog.IsQuestFlaggedCompleted = nil
    c.event("GOSSIP_SHOW"); c.advance(6)
    local core, me = c.ns.engine, c.ns.engine.me
    assert(core:confirm(me, "R") and core:rows()[1].source == "leader")
    c.env.C_QuestLog.IsQuestFlaggedCompleted = history
    c.event("QUEST_LOG_UPDATE")
    assert(core:rows()[1].status == "Unknown" and not core.manual[me],
        "resolving unknown history to false must discard the earlier assessment")
    c.advance(6)
    assert(core:confirm(me, "R"), "a helper need not have completed the actor's Love Potion")
    c.state[4201].rewarded = true
    c.event("QUEST_LOG_UPDATE")
    assert(core:rows()[1].status == "Unknown" and not core.manual[me],
        "changed relevant history must require a new assessment")
end)
test("Nagmara unrelated quest updates preserve confirmation", function()
    local c = client({guid = "Creature-0-1-1-1-9500-0001"})
    c.state[4201].rewarded = true
    c.event("GOSSIP_SHOW"); c.advance(6)
    local core = c.ns.engine
    assert(core:confirm(core.me, "R"))
    local fingerprint = core:fingerprint()
    c.state[99999] = {active = true, complete = true, rewarded = true}
    c.event("QUEST_LOG_UPDATE")
    assert(core:fingerprint() == fingerprint and core:rows()[1].source == "leader",
        "unrelated quest history must not reset the leader's assessment")
end)
test("distinct trap objects require distinct preparation without matching NPC gossip", function()
    local options = {guid = "GameObject-0-1-1-1-179485-0001"}
    local c = client(options); c.setQuest(1193)
    c.event("QUEST_PROGRESS"); c.advance(6)
    local core = c.ns.engine
    assert(core:confirm(core.me, "R"))
    local key = core.active.key
    c.event("QUEST_COMPLETE")
    assert(core.active.key == key and core:rows()[1].source == "leader",
        "the same object's reward screen must preserve preparation")
    options.guid = "GameObject-0-1-1-1-179485-0002"
    c.event("QUEST_PROGRESS")
    assert(core.active.key ~= key and not core.manual[core.me] and not core:allReady(),
        "a different observed trap must not inherit the first trap's confirmation")
    c = client({guid = "GameObject-0-1-1-1-7998-0001"})
    c.event("GOSSIP_SHOW")
    assert(not c.ns.engine.active, "an object entry must not impersonate an NPC identity")
end)
test("dungeon turn-ins warn on progress and reward screens, including objects", function()
    for _, id in ipairs({4295, 5525, 7429, 1193, 96335}) do
        local c = client({guid = "GameObject-0-1-1-1-179485-0001"})
        c.setQuest(id); c.event("QUEST_DETAIL"); assert(not c.ns.engine.active)
        c.event("QUEST_PROGRESS"); assert(c.ns.engine.active.ruleID == "t" .. id)
        local key = c.ns.engine.active.key
        c.event("QUEST_COMPLETE"); assert(c.ns.engine.active.key == key and not c.ns.engine.active.started)
        c.event("QUEST_TURNED_IN", id); assert(c.ns.engine.active.started)
        c.event("QUEST_PROGRESS"); assert(c.ns.engine.active.key == key and not c.ns.engine:allReady())
    end
end)
test("Alcaz key objective gates coordinated hand-ins without requiring witnesses", function()
    local c = client(); c.setQuest(96335)
    c.state[96335] = {active = true, complete = false, rewarded = false}
    c.event("QUEST_PROGRESS"); c.advance(6)
    assert(c.ns.engine:rows()[1].status == "Not Ready")
    c.state[96335].complete = true; c.event("QUEST_LOG_UPDATE"); c.advance(6)
    assert(c.ns.engine:allReady())
    c = client(); c.setQuest(96335); c.event("QUEST_PROGRESS"); c.advance(6)
    assert(c.ns.engine:rows()[1].status == "Unknown")
end)
print("adapter: " .. passed .. " scenario groups passed (mocked APIs/UI)")
