local NS = {}
assert(loadfile("ZKIRPartyQuesting/Rules.lua"))("ZKIR", NS)
assert(loadfile("ZKIRPartyQuesting/Core.lua"))("ZKIR", NS)
assert(loadfile("ZKIRPartyQuesting/Facts.lua"))("ZKIR", NS)
local A, B, C, D, E = "Alice-Realm", "Bob-Realm", "Cara-Realm", "Dan-Realm", "Eve-Realm"
local function eq(a, b, message) assert(a == b, (message or "equality") .. ": " .. tostring(a) .. " ~= " .. tostring(b)) end
local function copy(t)
    if type(t) ~= "table" then return t end
    local c = {}; for k, v in pairs(t) do c[k] = copy(v) end; return c
end
local function fact(state, signature) return {state = state or "R", reason = "TEST", signature = signature or state or "R"} end
local World = {}; World.__index = World
function World:add(name, saved)
    self.boots[name] = (self.boots[name] or 0) + 1
    local node = {name = name, want = fact(), saved = saved or {}}
    self.nodes[name] = node
    node.core = NS.New({me = name, now = function() return self.t end, wall = function() return 1000 + math.floor(self.t) end,
        boot = tostring(self.boots[name]), saved = node.saved, changed = function() end,
        send = function(payload)
            self.sends = self.sends + 1
            assert(#payload <= 255)
            if self.blockSend[name] then return false end
            local msg = {sender = name, payload = payload, at = self.t + (self.delays and (self.sends * 7 % 5) * 0.2 or 0)}
            self.queue[#self.queue + 1] = msg; self.wire[#self.wire + 1] = copy(msg)
            return true
        end,
        chat = function(text)
            if self.blockChat[name] then return false end
            self.chats[#self.chats + 1] = {sender = name, text = text}; return true
        end})
    node.core:setRoster(self.roster)
    return node
end
function World.new(members, responders)
    local self = setmetatable({t = 0, nodes = {}, boots = {}, roster = {}, queue = {}, wire = {}, chats = {},
        blockSend = {}, blockChat = {}, sends = 0}, World)
    for i, name in ipairs(members) do self.roster[i] = {name = name, connected = true, leader = i == 1} end
    for _, name in ipairs(responders or members) do self:add(name) end
    return self
end
function World:rosterChanged()
    for _, n in pairs(self.nodes) do n.core:setRoster(self.roster) end
end
function World:deliver(msg)
    for name, n in pairs(self.nodes) do
        if name ~= msg.sender and not n.paused and not (self.drop and self.drop(msg, name)) then
            n.core:receive(msg.sender, msg.payload)
            if self.duplicate then n.core:receive(msg.sender, msg.payload) end
        end
    end
end
function World:flush()
    local rounds = 0
    while true do
        rounds = rounds + 1; assert(rounds < 100, "echo loop")
        local batch, delivered = self.queue, false; self.queue = {}
        for _, msg in ipairs(batch) do
            if msg.at <= self.t then self:deliver(msg); delivered = true
            else self.queue[#self.queue + 1] = msg end
        end
        if not delivered then return end
    end
end
function World:pump(seconds)
    local finish = self.t + seconds
    while self.t < finish do
        self.t = math.min(finish, self.t + 0.25)
        for _, n in pairs(self.nodes) do
            if not n.paused then
                if n.core.active then n.core:setFact(n.want) end
                n.core:tick()
            end
        end
        self:flush()
    end
end
function World:start(name)
    self.nodes[name or A].core:detect("a155", "npc"); self:pump(25)
end
function World:row(observer, name)
    for _, row in ipairs(self.nodes[observer].core:rows()) do if row.name == name then return row end end
    error("missing member " .. name)
end
function World:ready()
    for _, n in pairs(self.nodes) do assert(n.core:allReady(), n.name .. " not ready") end
end
function World:chatCount(count, sender)
    eq(#self.chats, count, "party chat count")
    if sender then for _, chat in ipairs(self.chats) do eq(chat.sender, sender, "chat sender") end end
end
local passed, failed = 0, 0
local function test(name, run)
    local ok, err = xpcall(run, debug.traceback)
    if ok then passed = passed + 1 else failed = failed + 1; print("FAIL " .. name .. "\n" .. err) end
end
test("2-5 automatic participants / leader only", function()
    local all = {A, B, C, D, E}
    for size = 2, 5 do
        local names = {}; for i = 1, size do names[i] = all[i] end
        local w = World.new(names); w:start(names[size]); w:ready(); w:chatCount(2, A)
    end
end)
test("mixed party / waiting / manual provenance", function()
    local w = World.new({A, B, C}, {A, B})
    w.nodes[B].core:detect("a155", "npc"); w:pump(1)
    eq(w:row(A, C).status, "Waiting")
    w:pump(24); eq(w:row(A, C).status, "Unknown"); w:chatCount(1, A)
    assert(not w.nodes[B].core:confirm(C, "R"))
    assert(w.nodes[A].core:confirm(C, "R")); w:pump(25)
    w:ready(); eq(w:row(B, C).source, "leader"); w:chatCount(2, A)
end)
test("A-Me repair facts synchronize before the escort is accepted", function()
    local w = World.new({A, B, C})
    local rule = assert(NS.Rules.a4245, "A-Me escort must synchronize by its shipped rule ID")
    local s = {level = 48, faction = "Horde", space = true, quests = {
        [4245] = {active = false, rewarded = false}, [4244] = {rewarded = true}}}
    for _, n in pairs(w.nodes) do n.want = NS.Evaluate(rule, s) end
    s.quests[4244] = {active = true, complete = true, rewarded = false}
    w.nodes[C].want = NS.Evaluate(rule, s)
    w.nodes[B].core:detect("a4245", "Creature-0-1-1-1-9623-0001"); w:pump(25)
    for _, name in ipairs({A, B, C}) do
        eq(w.nodes[name].core.active.ruleID, "a4245")
        eq(w:row(name, C).status, "Not Ready")
        assert(not w.nodes[name].core:allReady())
    end
    assert(not w.nodes[A].core:confirm(C, "R")); w:chatCount(1, A)
    assert(w.chats[1].text:find(rule.warning, 1, true))
    s.quests[4244] = {rewarded = true}; w.nodes[C].want = NS.Evaluate(rule, s)
    w:pump(25); w:ready(); w:chatCount(2, A)
    assert(w.chats[2].text:find(rule.nextAction, 1, true))
    w.nodes[B].core:detect("a4245", "Creature-0-1-1-1-9623-0001"); w:pump(25); w:chatCount(2, A)
    w.nodes[B].core:action(4245, "accept"); w:pump(1)
    for _, n in pairs(w.nodes) do assert(n.core.active.started and not n.core:allReady()) end
end)
test("no addon leader / alphabetical fallback has no manual authority", function()
    local w = World.new({A, B, C}, {C, B}); w:start(C); w:chatCount(1, B)
    assert(not w.nodes[B].core:confirm(A, "R")); assert(not w.nodes[B].core:allReady())
end)
test("blocker cannot be concealed and resolves automatically", function()
    local w = World.new({A, B, C}); w.nodes[C].want = fact("N"); w:start()
    eq(w:row(A, C).status, "Not Ready"); assert(not w.nodes[A].core:confirm(C, "R")); w:chatCount(1, A)
    w.nodes[C].want = fact("R", "handed-in"); w:pump(25); w:ready(); w:chatCount(2, A)
end)
test("insufficient evidence / confirmations survive unrelated updates", function()
    local w = World.new({A, B, C}); w.nodes[C].want = fact("U"); w:start()
    eq(w:row(A, C).status, "Unknown"); assert(w.nodes[A].core:confirm(C, "R")); w:pump(25); w:ready()
    w:pump(35); w:ready(); eq(w:row(A, C).source, "leader"); w:chatCount(2, A)
    w.nodes[B].want = fact("R", "relevant-change"); w:pump(25)
    eq(w:row(A, C).status, "Unknown"); assert(not w.nodes[A].core:allReady())
end)
test("disconnection overrides manual / reconnection does not resurrect it", function()
    local w = World.new({A, B, C}, {A, B}); w:start()
    w.nodes[A].core:confirm(C, "R"); w:pump(25); w:ready()
    w.roster[3].connected = false; w:rosterChanged(); w:pump(2)
    eq(w:row(A, C).status, "Not Ready"); assert(not w.nodes[A].core:confirm(C, "R"))
    w.roster[3].connected = true; w:rosterChanged(); w:pump(25)
    eq(w:row(A, C).status, "Unknown")
end)
test("retry drops manual and rejects replay", function()
    local w = World.new({A, B, C}, {A, B}); w:start()
    w.nodes[A].core:confirm(C, "R"); w:pump(25); local traffic = copy(w.wire)
    assert(w.nodes[A].core:retry()); w:pump(25); local key = w.nodes[A].core.active.key
    w:chatCount(3, A)
    for _, msg in ipairs(traffic) do w:deliver(msg) end
    w:pump(25); eq(w.nodes[B].core.active.key, key); eq(w:row(B, C).status, "Unknown"); w:chatCount(3, A)
    w.nodes[A].core:confirm(C, "R"); w:pump(25); w:ready(); w:chatCount(4, A)
end)
test("leader change invalidates confirmations without repeat chat", function()
    local w = World.new({A, B, C}, {A, B}); w:start(); w.nodes[A].core:confirm(C, "R"); w:pump(25)
    w.roster[1].leader = false; w.roster[2].leader = true; w:rosterChanged(); w:pump(25)
    eq(w:row(B, C).status, "Unknown"); assert(not w.nodes[A].core:confirm(C, "R"))
    assert(w.nodes[B].core:confirm(C, "R")); w:pump(25); w:ready(); w:chatCount(2)
end)
test("coordinator reload / repeated detection / all-client reload", function()
    local w = World.new({A, B, C}); w:start(B); w:chatCount(2, A)
    w:add(A, w.nodes[A].saved); w:pump(25); w:ready(); w:chatCount(2, A)
    w.nodes[B].core:detect("a155", "npc"); w:pump(25); w:chatCount(2, A)
    for _, name in ipairs({A, B, C}) do w:add(name, w.nodes[name].saved) end
    w:pump(25); w:ready(); w:chatCount(2, A)
end)
test("simultaneous detectors / duplicate reordered messages", function()
    local w = World.new({A, B, C}); w.delays, w.duplicate = true, true
    for _, n in pairs(w.nodes) do n.core:detect("a155", "npc") end
    w:pump(30)
    eq(w.nodes[A].core.active.key, w.nodes[B].core.active.key)
    eq(w.nodes[A].core.active.key, w.nodes[C].core.active.key)
    w:ready(); w:chatCount(2, A)
end)
test("unavailable sends stop without spam / retry recovers", function()
    local w = World.new({A, B}); w.blockSend[A] = true; w:start()
    assert(not w.nodes[A].core:allReady()); w:chatCount(0); local sends = w.sends
    w:pump(60); eq(w.sends, sends, "failed transport must latch")
    w.blockSend[A] = nil; w.nodes[A].core:retry(); w:pump(25); w:ready(); w:chatCount(2, A)
end)
test("chat failure is not retried or delegated", function()
    local w = World.new({A, B}); w.blockChat[A] = true; w:start(); w:pump(60); w:chatCount(0)
    w.blockChat[A] = nil; w:pump(30); w:chatCount(0)
end)
test("heartbeat expiry prevents readiness / cannot manually bypass", function()
    local w = World.new({A, B}); w:start(); w.nodes[B].paused = true; w:pump(15)
    assert(not w.nodes[A].core:allReady()); assert(not w.nodes[A].core:confirm(B, "R")); w:chatCount(2, A)
end)
test("late addon and stale packets cannot hide a verified blocker", function()
    local w = World.new({A, B, C}, {A, B}); w:start(); w.nodes[A].core:confirm(C, "R"); w:pump(25)
    w:add(C).want = fact("N"); w:pump(25)
    eq(w:row(A, C).status, "Not Ready"); assert(not w.nodes[A].core:allReady())
    w.nodes[C].want = fact("U"); w:pump(25)
    eq(w:row(A, C).status, "Not Ready"); assert(not w.nodes[A].core:confirm(C, "R"))
end)
test("normal action retires preparation, solo never sends chat", function()
    local w = World.new({A}); w:start(); w:ready(); w:chatCount(0)
    w.nodes[A].core:action(155, "accept"); assert(not w.nodes[A].core:allReady())
    local x = World.new({A, B}); x:start(); x.nodes[B].core:action(155, "accept"); x:pump(1)
    assert(x.nodes[A].core.active.started); assert(not x.nodes[A].core:allReady())
end)
test("untrusted malformed/outsider packets do not throw or confirm", function()
    local w = World.new({A, B}); w:start()
    for _, data in ipairs({"", "1|E", "1|F", "1|M", "2|E|fake", string.rep("x", 256)}) do
        w.nodes[A].core:receive(B, data); w.nodes[A].core:receive("Stranger-Realm", data)
    end
    w:pump(2); w:chatCount(2, A)
end)
test("manual ordering and change-away-and-back reject stale decisions", function()
    local w = World.new({A, B, C}, {A, B}); w:start()
    w.nodes[A].core:confirm(C, "R"); w:pump(25)
    local old = copy(w.wire)
    w.nodes[A].core:confirm(C, "N"); w:pump(5)
    for _, msg in ipairs(old) do w:deliver(msg) end
    eq(w:row(B, C).status, "Not Ready", "older Ready cannot replace newer manual Not Ready")
    w.nodes[B].want = fact("N"); w:pump(5); w.nodes[B].want = fact(); w:pump(10)
    for _, msg in ipairs(old) do w:deliver(msg) end
    eq(w:row(B, C).status, "Unknown", "same facts after a transition need a fresh decision")
    w.nodes[A].core:confirm(C, "R"); w:pump(10); old = copy(w.wire)
    w.roster[3].connected = false; w:rosterChanged(); w.pump(w, 1)
    w.roster[3].connected = true; w:rosterChanged(); w:pump(10)
    for _, msg in ipairs(old) do w:deliver(msg) end
    eq(w:row(B, C).status, "Unknown", "same roster after reconnect cannot revive manual")
end)
test("previously unseen old boot is rejected", function()
    local w = World.new({A, B}); w:start()
    local a, key = w.nodes[A].core, w.nodes[A].core.active.key
    a:receive(B, "1|H|" .. key .. "|3")
    a:receive(B, "1|H|" .. key .. "|2")
    eq(a.peers[B].boot, "3")
end)
test("pending announcement survives a relevant update without duplicate", function()
    local w = World.new({A, B}); w.nodes[A].core:detect("a155", "npc"); w:pump(5.75)
    w.nodes[B].want = fact("R", "new-preparation"); w:pump(25)
    w:ready(); w:chatCount(2, A)
end)
test("leader without addon can confirm through authentic token-bound party chat", function()
    local w = World.new({A, B, C}, {B, C}); w:start(B); w:chatCount(1, B)
    local token = w.nodes[B].core:fingerprint()
    for _, n in pairs(w.nodes) do
        assert(not n.core:confirmFromChat(C, token, A, "R", 1))
        assert(not n.core:confirmFromChat(A, "old-token", A, "R", 2))
        assert(n.core:confirmFromChat(A, token, A, "R", 3))
        assert(not n.core:confirmFromChat(A, token, A, "R", 3))
    end
    w:pump(25); w:ready(); w:chatCount(2, B)
    w.nodes[B].core:retry(); w:pump(25)
    assert(not w.nodes[B].core:confirmFromChat(A, token, A, "R", 4))
end)
test("late leader discovery preserves the fallback's initial receipt", function()
    local w = World.new({A, B, C}, {B, C}); w.nodes[B].core:detect("a155", "npc"); w:pump(9)
    w:chatCount(1, B); w:add(A); w:pump(25); w:ready(); w:chatCount(2)
    eq(w.chats[2].sender, A, "actual leader owns next action after discovery")
end)
test("lost acknowledgement is retransmitted without repeating chat", function()
    local w = World.new({A, B}); local dropped = false
    w.drop = function(msg)
        if not dropped and msg.payload:match("^1|K|") then dropped = true; return true end
    end
    w:start(); assert(dropped); w:ready(); w:chatCount(2, A)
end)
test("working heartbeats do not keep lost facts ready forever", function()
    local w = World.new({A, B}); w:start()
    w.drop = function(msg, target) return msg.sender == B and target == A and msg.payload:match("^1|F|") end
    w.nodes[B].want = fact("N"); w:pump(14)
    eq(w:row(A, B).status, "Unknown"); assert(not w.nodes[A].core:allReady()); w:chatCount(2, A)
    assert(not w.nodes[A].core:confirm(B, "R"), "expired addon facts cannot be replaced by manual approval")
end)
test("reloading a client that missed multiple attempts resynchronizes", function()
    local w = World.new({A, B}); w:start(); w.nodes[A].paused = true
    w.nodes[B].core:retry(); w:pump(10); w.nodes[B].core:retry(); w:pump(10)
    local current = w.nodes[B].core.active.key
    w:add(A, w.nodes[A].saved); w:pump(25)
    eq(w.nodes[A].core.active.key, current); w:ready()
end)
test("expanded catalogue synchronizes mixed parties and retires each action", function()
    for _, rule in pairs(NS.Rules) do
        local w = World.new({A, B, C}, {A, B})
        local s = {level = 60, space = true, faction = rule.faction == "Both" and "Alliance" or rule.faction,
            classID = rule.classID or 1, raceID = rule.raceIDs and rule.raceIDs[1] or 1, quests = {}}
        if rule.questID then s.quests[rule.questID] = {rewarded = false,
            active = rule.kind == "gossip" or rule.finishTogether == true,
            complete = rule.finishTogether == true, failed = false} end
        for _, id in ipairs(rule.prerequisites) do s.quests[id] = {rewarded = true, active = false} end
        for _, id in ipairs(rule.exclusive or {}) do s.quests[id] = {rewarded = false, active = false} end
        for _, n in pairs(w.nodes) do n.want = NS.Evaluate(rule, s) end
        w.nodes[B].core:detect(rule.id, "npc"); w:pump(25); w:chatCount(1, A)
        for _, n in pairs(w.nodes) do eq(n.core.active.ruleID, rule.id) end
        eq(w:row(A, C).status, "Unknown")
        for _, name in ipairs({A, B, C}) do
            if w:row(A, name).status == "Unknown" then assert(w.nodes[A].core:confirm(name, "R")) end
        end
        w:pump(25); w:ready(); w:chatCount(2, A)
        eq(w.chats[2].text, "ZKIR: " .. rule.nextAction)
        w.nodes[B].core:action(rule.questID, rule.kind); w:pump(1)
        for _, n in pairs(w.nodes) do assert(n.core.active.started and not n.core:allReady()) end
    end
end)
print("core: " .. passed .. " scenario groups passed; " .. failed .. " failed")
assert(failed == 0, "protocol simulations failed")
