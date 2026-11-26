local NS = {}
assert(loadfile("ZKIRPartyQuesting/Messages.lua"))("ZKIR", NS)
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
local function envelope(a, started)
    return table.concat({"1", "E", a.key, a.parent, a.ruleID, a.context, tostring(a.time), started and "1" or "0"}, "|")
end
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
test("presentation reports evidence and action readiness from the same snapshot", function()
    local w = World.new({A, B})
    w.nodes[A].core:detect("a155", "npc"); w:pump(1)
    local core = w.nodes[A].core
    local settling = core:presentation()
    eq(#settling.rows, 2); assert(not settling.ready, "visible evidence must still wait for discovery")
    w:pump(24)
    local prepared = core:presentation()
    assert(prepared.ready); eq(prepared.fingerprint, core:fingerprint())
    for _, row in ipairs(prepared.rows) do eq(row.status, "Ready") end
    core:action(155, "accept")
    local finished = core:presentation()
    assert(not finished.ready, "a completed preparation cannot show permission to proceed again")
    for _, row in ipairs(finished.rows) do eq(row.status, "Ready", "ending preparation retains the last evidence") end
    assert(prepared.ready, "a returned snapshot does not change after later transitions")
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
test("completed solo actions cannot open or announce an old event to a later party", function()
    for _, ruleID in ipairs({"a155", "t4201", "g2078"}) do
        for _, reload in ipairs({false, true}) do
            local w = World.new({A}); local rule = NS.Rules[ruleID]
            w.nodes[A].core:detect(ruleID, "solo-npc"); w:pump(6)
            w.nodes[A].core:action(rule.questID, rule.kind); w:pump(1)
            assert(w.nodes[A].core.active.started)
            if reload then w:add(A, w.nodes[A].saved) end
            w.roster[2] = {name = B, connected = true, leader = false}
            w:rosterChanged(); w:add(B); w:pump(30)
            w:chatCount(0)
            assert(not w.nodes[B].core.active, "fresh party member must not adopt the completed solo event")
            assert(not w.nodes[A].core:allReady(), "completed solo preparation stays retired after joining")
            for _, message in ipairs(w.wire) do
                assert(not message.payload:match("^1|[EQ]|"), "completed solo event cannot start new discovery or announcement claims")
            end
        end
    end
end)
test("retired solo histories do not block a new party event or its actual leader", function()
    for _, bothHaveHistory in ipairs({false, true}) do
        for _, reload in ipairs({false, true}) do
            local w = World.new({A})
            w.nodes[A].core:detect("a155", "alice-solo"); w:pump(1)
            local oldAlice = copy(w.nodes[A].core.active)
            w.nodes[A].core:action(155, "accept")
            local bobSaved, oldBob
            if bothHaveHistory then
                local solo = World.new({B})
                solo.nodes[B].core:detect("a4245", "bob-solo"); solo:pump(1)
                oldBob = copy(solo.nodes[B].core.active)
                solo.nodes[B].core:action(4245, "accept")
                bobSaved = solo.nodes[B].saved
            end
            w.roster[2] = {name = B, connected = true, leader = false}
            w:rosterChanged(); w:add(B, bobSaved)
            if reload then w:add(A, w.nodes[A].saved) end
            w:pump(8); w:chatCount(0)

            w.nodes[B].core:detect("a452", "new-party-npc"); w:pump(25)
            local current = w.nodes[B].core.active.key
            for _, n in pairs(w.nodes) do
                eq(n.core.active.key, current, "both clients must discover the new party attempt")
                eq(n.core.active.ruleID, "a452")
                assert(not n.core.active.started)
            end
            w:ready(); w:chatCount(2, A)
            for _, started in ipairs({false, true}) do
                w.nodes[B].core:receive(A, envelope(oldAlice, started))
                if oldBob then w.nodes[A].core:receive(B, envelope(oldBob, started)) end
            end
            w.nodes[B].core:receive(A, "1|X|" .. oldAlice.key)
            if oldBob then w.nodes[A].core:receive(B, "1|X|" .. oldBob.key) end
            w:pump(8)
            for _, n in pairs(w.nodes) do eq(n.core.active.key, current) end
            w:ready(); w:chatCount(2, A)
        end
    end
end)
test("a party can prepare the same NPC after its leader completed it solo", function()
    local w = World.new({A})
    w.nodes[A].core:detect("a155", "same-npc"); w:pump(1)
    w.nodes[A].core:action(155, "accept")
    w.roster[2] = {name = B, connected = true, leader = false}
    w:rosterChanged(); w:add(B)
    w.nodes[A].want = fact("N", "already-started-solo")
    w.nodes[B].core:detect("a155", "same-npc"); w:pump(25)
    local current = w.nodes[B].core.active.key
    for _, n in pairs(w.nodes) do
        eq(n.core.active.key, current)
        assert(not n.core.active.started, "an earlier solo action cannot retire the new party attempt")
    end
    eq(w:row(B, A).status, "Not Ready")
    assert(not w.nodes[A].core:allReady()); w:chatCount(1, A)
end)
test("delayed same-NPC envelopes from a previous party cannot retire its fresh attempt", function()
    for _, started in ipairs({false, true}) do
        local w = World.new({A, B, C}, {A, C})
        w.nodes[A].core:detect("a155", "same-npc")
        local old = copy(w.nodes[A].core.active)
        w:pump(1); w.nodes[A].core:action(155, "accept"); w:pump(1)
        w.roster[3], w.nodes[C] = nil, nil
        w:rosterChanged(); w:add(B)
        w.nodes[B].core:detect("a155", "same-npc")
        local current = w.nodes[B].core.active.key
        w.nodes[B].core:receive(A, envelope(old, started)); w:pump(30)
        for _, n in pairs(w.nodes) do
            eq(n.core.active.key, current)
            assert(not n.core.active.started, "past-party traffic is not evidence this party started its event")
        end
        w:ready(); w:chatCount(2, A)
    end
end)
test("simultaneous different detections converge without reopening the losing event", function()
    local w = World.new({A, B}); w.delays, w.duplicate = true, true
    w.nodes[A].core:detect("a155", "alice-npc")
    w.nodes[B].core:detect("a4245", "bob-npc")
    local alice, bob = copy(w.nodes[A].core.active), copy(w.nodes[B].core.active)
    w:pump(30)
    local current = w.nodes[A].core.active.key
    eq(w.nodes[B].core.active.key, current, "independent discoveries must agree on one compact window")
    w:ready(); w:chatCount(2, A)
    w.nodes[A].core:receive(B, envelope(bob, false))
    w.nodes[B].core:receive(A, envelope(alice, false))
    w:pump(10)
    for _, n in pairs(w.nodes) do eq(n.core.active.key, current) end
    w:ready(); w:chatCount(2, A)
end)
test("new interactions and retries remain fresh after party retirement and old traffic", function()
    local w = World.new({A, B}); w:start()
    w.nodes[B].core:action(155, "accept"); w:pump(5)
    local retiredTraffic = copy(w.wire)
    w.nodes[B].core:detect("a4245", "next-npc"); w:pump(25)
    local nextKey = w.nodes[B].core.active.key
    for _, n in pairs(w.nodes) do eq(n.core.active.key, nextKey) end
    w:ready(); w:chatCount(4, A)
    for _, message in ipairs(retiredTraffic) do w:deliver(message) end
    w:pump(5)
    for _, n in pairs(w.nodes) do eq(n.core.active.key, nextKey) end
    w:ready(); w:chatCount(4, A)
    local previousTraffic = copy(w.wire)
    assert(w.nodes[A].core:retry()); w:pump(25)
    local retryKey = w.nodes[A].core.active.key
    assert(retryKey ~= nextKey)
    for _, message in ipairs(previousTraffic) do w:deliver(message) end
    w:pump(8)
    for _, n in pairs(w.nodes) do eq(n.core.active.key, retryKey) end
    w:ready(); w:chatCount(6, A)
end)
test("unseen old event envelopes cannot reopen a retired interaction", function()
    for _, movedOn in ipairs({false, true}) do
        local w = World.new({A, B})
        w.nodes[A].core:detect("a155", "alice-npc"); w.nodes[A].core:action(155, "accept")
        w.nodes[B].core:detect("a4245", "bob-old-npc")
        local current, stale = copy(w.nodes[A].core.active), copy(w.nodes[B].core.active)
        if movedOn then w.nodes[B].core:detect("a452", "bob-current-npc")
        else w.nodes[B].core:action(4245, "accept") end
        w.queue = {}
        w.drop = function(message, recipient)
            return message.sender == B and recipient == A and message.payload:match("^1|E|")
        end
        w.nodes[A].core:receive(B, envelope(stale, false)); w:flush(); w:pump(15)
        eq(w.nodes[A].core.active.key, current.key)
        assert(w.nodes[A].core.active.started and not w.nodes[A].core:allReady(),
            "an unseen delayed envelope cannot reopen a completed current interaction")
        for _, message in ipairs(w.wire) do
            if message.payload:find("1|Y|" .. stale.key .. "|", 1, true) == 1 then
                assert(not movedOn and message.payload:match("|1$"),
                    "a sender must not authenticate a started or replaced event as pending")
            end
        end
        for _, chat in ipairs(w.chats) do assert(chat.sender ~= A, "retired leader cannot warn about replayed events") end
    end
end)
test("an unseen replaced child event cannot roll back a completed parent", function()
    local w = World.new({A, B}); w:start()
    w.nodes[A].core:action(155, "accept"); w:pump(1)
    local parentKey = w.nodes[A].core.active.key
    w.nodes[B].core:detect("a4245", "old-child-npc")
    local stale = copy(w.nodes[B].core.active)
    eq(stale.parent, parentKey)
    w.nodes[B].core:detect("a452", "current-npc")
    local currentKey = w.nodes[B].core.active.key
    w.queue = {}
    w.nodes[A].core:receive(B, envelope(stale, false)); w:flush()
    eq(w.nodes[A].core.active.key, parentKey, "a parent link alone cannot authenticate an unseen child")
    assert(w.nodes[A].core.active.started)
    w.nodes[B].core:broadcast(); w:pump(25)
    for _, n in pairs(w.nodes) do eq(n.core.active.key, currentKey) end
    w:ready(); w:chatCount(4, A)
end)
local function delayedReconciliation()
    local w = World.new({A, B})
    w.nodes[A].core:detect("a155", "alice-npc"); w.nodes[A].core:action(155, "accept")
    w.nodes[B].core:detect("a4245", "bob-npc")
    local current, candidate = copy(w.nodes[A].core.active), copy(w.nodes[B].core.active)
    w.queue = {}
    local reply
    w.drop = function(message, recipient)
        if message.sender == B and recipient == A then
            if message.payload:match("^1|Y|") then reply = copy(message); return true end
            return message.payload:match("^1|E|") ~= nil
        end
    end
    w.nodes[A].core:receive(B, envelope(candidate, false)); w:flush()
    assert(reply, "fixture must hold a live reconciliation response before delivery")
    eq(w.nodes[A].core.active.key, current.key, "a probe alone cannot replace the current event")
    return w, reply, current, candidate
end
test("delayed reconciliation replies cannot cross roster, event, reload, or expiry boundaries", function()
    for _, transition in ipairs({"roster", "event", "reload", "expiry"}) do
        local w, reply = delayedReconciliation()
        if transition == "roster" then
            w.roster[2].connected = false; w:rosterChanged()
            w.roster[2].connected = true; w:rosterChanged()
        elseif transition == "event" then
            w.nodes[A].core:detect("a452", "replacement-npc")
        elseif transition == "reload" then
            w:add(A, w.nodes[A].saved)
        else w.t = w.t + 13 end
        local expected = w.nodes[A].core.active.key
        w.nodes[A].core:receive(reply.sender, reply.payload)
        eq(w.nodes[A].core.active.key, expected, "an old response cannot survive " .. transition)
    end
end)
test("a candidate's action before its delayed reply prevents reopening that event", function()
    local w, reply, current = delayedReconciliation()
    w.nodes[B].core:action(4245, "accept"); w:flush()
    w.nodes[A].core:receive(reply.sender, reply.payload); w:pump(15)
    eq(w.nodes[A].core.active.key, current.key)
    assert(w.nodes[A].core.active.started and not w.nodes[A].core:allReady())
    w:chatCount(0)
end)
test("concurrent aliases learn an action that overtakes a delayed pending reply", function()
    local w = World.new({A, B})
    w.nodes[A].core:detect("a155", "same-npc")
    w.nodes[B].core:detect("a155", "same-npc")
    local candidate, reply = copy(w.nodes[B].core.active)
    w.queue = {}
    w.drop = function(message, recipient)
        if message.sender == B and recipient == A then
            if message.payload:match("^1|Y|") then reply = copy(message); return true end
            return message.payload:match("^1|E|") ~= nil
        end
    end
    w.nodes[A].core:receive(B, envelope(candidate, false)); w:flush()
    assert(reply, "fixture must delay a live pending-alias response")
    w.nodes[B].core:action(155, "accept"); w:flush()
    w.nodes[A].core:receive(reply.sender, reply.payload)
    w.drop = nil; w:pump(25)
    eq(w.nodes[A].core.active.key, w.nodes[B].core.active.key)
    for _, n in pairs(w.nodes) do
        assert(n.core.active.started and not n.core:allReady(), "same-party action must eventually retire both aliases")
    end
    w:chatCount(0)
end)
test("a delayed reconciliation reply cannot clear a latched messaging failure", function()
    local w, reply, current, candidate = delayedReconciliation()
    w.blockSend[A] = true
    assert(not w.nodes[A].core:send("V", candidate.key, "failed-probe"))
    assert(not w.nodes[A].core.healthy)
    w.nodes[A].core:receive(reply.sender, reply.payload)
    eq(w.nodes[A].core.active.key, current.key)
    assert(not w.nodes[A].core.healthy and not w.nodes[A].core:allReady(),
        "a response in flight cannot silently recover a failed outbound transport")
end)
test("a fresh live probe recovers a failed completed interaction after joining a new party", function()
    local w = World.new({A, C}); w:start(C); w:ready(); w:chatCount(2, A)
    w.blockSend[A] = true
    w.nodes[A].core:action(155, "accept")
    assert(w.nodes[A].core.active.started and not w.nodes[A].core.healthy)
    w.nodes[C].core:action(155, "accept"); w:pump(1)
    w.nodes[C] = nil
    w.roster[2] = {name = B, connected = true, leader = false}
    w.blockSend[A] = nil
    w:rosterChanged(); w:add(B)
    w.nodes[B].core:detect("a4245", "new-party-npc"); w:pump(25)
    local current = w.nodes[B].core.active.key
    for _, n in pairs(w.nodes) do
        eq(n.core.active.key, current)
        assert(n.core.healthy and not n.core.active.started)
    end
    w:ready(); w:chatCount(4, A)
end)
test("a failed recovery probe does not retry on repeated event envelopes", function()
    local w = World.new({A, B})
    w.nodes[A].core:detect("a155", "alice-npc")
    w.blockSend[A] = true; w.nodes[A].core:action(155, "accept")
    assert(not w.nodes[A].core.healthy)
    w.nodes[B].core:detect("a4245", "bob-npc")
    local candidate = copy(w.nodes[B].core.active)
    w.queue = {}
    local sends = w.sends
    for i = 1, 20 do
        w.t = i * 4
        w.nodes[A].core:receive(B, envelope(candidate, false))
    end
    eq(w.sends, sends + 1, "one failed probe must latch across subsequent pulses and expiry")
    w.blockSend[A] = nil
    w.nodes[A].core:receive(B, envelope(candidate, false))
    eq(w.sends, sends + 1, "time or restored API availability alone must not retry a failed probe")
    w.roster[2].connected = false; w:rosterChanged()
    w.roster[2].connected = true; w:rosterChanged()
    w.nodes[A].core:receive(B, envelope(candidate, false)); w:flush(); w:pump(25)
    eq(w.nodes[A].core.active.key, candidate.key)
    assert(w.nodes[A].core.healthy)
    w:ready(); w:chatCount(2, A)
end)
test("action during an initial announcement claim cancels local and remote late warnings", function()
    for _, actor in ipairs({A, B}) do
        local w = World.new({A, B}); w.nodes[A].core:detect("a155", "npc"); w:pump(6)
        local owner = w.nodes[A].core
        assert(owner.pending and owner.pending.stage == "I", "fixture must have an in-flight initial claim")
        w:chatCount(0)
        local key, fingerprint = owner.active.key, owner.pending.fingerprint
        w.nodes[actor].core:action(155, "accept"); w:pump(0.25)
        assert(owner.active.started and not owner.pending, "observed action cancels the claim before its delay expires")
        local before = #w.wire
        w.nodes[B].core:receive(A, "1|Q|" .. key .. "|I|" .. fingerprint)
        eq(#w.wire, before, "late claim cannot receive a new acknowledgement after action")
        owner:receive(B, "1|K|" .. key .. "|I|" .. fingerprint)
        w:pump(25); w:chatCount(0)
    end
end)
test("started event packets retire the current attempt but cannot create or replace a session", function()
    local w = World.new({A, B}); local receiver = w.nodes[B].core
    receiver:receive(A, "1|E|1000.old.1|0|a155|old-npc|1000|1")
    assert(not receiver.active, "already-started traffic cannot open a new session")
    receiver:detect("a4245", "current-npc")
    local current = copy(receiver.active)
    receiver:receive(A, table.concat({"1", "E", "1000.old.2", current.key, "a155", "old-npc", "1000", "1"}, "|"))
    eq(receiver.active.key, current.key, "already-started traffic cannot replace an unrelated active attempt")
    assert(not receiver.active.started)

    w = World.new({A, B}); w.nodes[A].core:detect("a155", "npc"); w:pump(6)
    receiver = w.nodes[A].core; current = copy(receiver.active)
    assert(receiver.pending and receiver.pending.stage == "I")
    receiver:receive(B, table.concat({"1", "E", current.key, current.parent, current.ruleID,
        current.context, tostring(current.time), "1"}, "|"))
    assert(receiver.active.started and not receiver.pending and not receiver:allReady(),
        "same-key started packet retires readiness and any pending announcement")
    receiver:receive(B, table.concat({"1", "E", current.key, current.parent, current.ruleID,
        current.context, tostring(current.time), "0"}, "|"))
    assert(receiver.active.started, "a late pre-action snapshot cannot reopen the completed attempt")
    w.nodes[B].core:action(155, "accept"); w:pump(25); w:chatCount(0)
end)
test("heartbeat recovers a lost immediate action message for existing participants", function()
    local w = World.new({A, B}); w:start(); local dropped = false
    w.drop = function(message, recipient)
        if not dropped and message.sender == B and recipient == A and message.payload:match("^1|X|") then
            dropped = true; return true
        end
    end
    w.nodes[B].core:action(155, "accept"); w:pump(0.25)
    assert(dropped and not w.nodes[A].core.active.started, "fixture must lose the immediate action notification")
    w:pump(6)
    assert(w.nodes[A].core.active.started and not w.nodes[A].core:allReady(),
        "existing participant learns retirement from repeated exact-event traffic")
    w:chatCount(2, A)
end)
test("completed party scope cannot return after members leave and rejoin", function()
    local w = World.new({A, B}); w:start(); w.nodes[B].core:action(155, "accept"); w:pump(1)
    local firstNewMessage = #w.wire + 1
    for _, member in ipairs({C, B}) do
        w.nodes[B], w.nodes[C] = nil, nil
        w.roster[2] = {name = member, connected = true, leader = false}
        w:rosterChanged(); w:add(member); w:pump(10)
        assert(not w.nodes[member].core.active, "new or rejoined client must not adopt the finished party event")
    end
    for i = firstNewMessage, #w.wire do
        assert(not w.wire[i].payload:match("^1|E|"), "the old roster returning must not restore permission to publish the finished event")
    end
    w:chatCount(2, A)
end)
test("concurrent aliases converge without undoing an already observed action", function()
    local w = World.new({A, B})
    w.nodes[A].core:detect("a155", "npc"); w.nodes[B].core:detect("a155", "npc")
    local higher = w.nodes[A].core.active.key > w.nodes[B].core.active.key and A or B
    local lower = higher == A and B or A
    local highCore, lowCore = w.nodes[higher].core, w.nodes[lower].core
    local high, low = copy(highCore.active), copy(lowCore.active)
    highCore:action(155, "accept")
    lowCore:receive(higher, table.concat({"1", "E", high.key, high.parent, high.ruleID,
        high.context, tostring(high.time), "1"}, "|"))
    w:pump(4)
    assert(lowCore.active.started, "known concurrent attempt can learn that its action already happened")
    highCore:receive(lower, table.concat({"1", "E", low.key, low.parent, low.ruleID,
        low.context, tostring(low.time), "0"}, "|"))
    assert(highCore.active.started, "lower pre-action alias cannot undo a locally observed action")
    w:pump(25)
    eq(highCore.active.key, lowCore.active.key, "concurrent attempts still converge")
    assert(highCore.active.started and lowCore.active.started)
    w:chatCount(0)
end)
test("an explicit retry after retirement starts a fresh coordinated attempt", function()
    local w = World.new({A, B}); w:start(); w.nodes[B].core:action(155, "accept"); w:pump(5)
    local completed, oldKey = copy(w.wire), w.nodes[A].core.active.key
    assert(w.nodes[A].core:retry(), "retired events still permit an explicit new attempt")
    local freshKey = w.nodes[A].core.active.key
    assert(freshKey ~= oldKey and not w.nodes[A].core.active.started)
    w:pump(25); w:ready(); w:chatCount(4, A)
    for _, message in ipairs(completed) do w:deliver(message) end
    w:pump(6)
    eq(w.nodes[A].core.active.key, freshKey); eq(w.nodes[B].core.active.key, freshKey)
    w:ready(); w:chatCount(4, A)
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
test("a client that misses several interactions catches up after peer expiry without reload", function()
    local w = World.new({A, B}); w:start()
    local previous = w.nodes[A].core.active.key
    w.nodes[A].paused = true
    w.nodes[B].core:detect("a4245", "second-npc"); w:pump(1)
    w.nodes[B].core:action(4245, "accept"); w:pump(1)
    w.nodes[B].core:detect("a452", "third-npc"); w:pump(1)
    local current = w.nodes[B].core.active.key
    w.nodes[A].paused = false; w:pump(5)
    eq(w.nodes[A].core.active.key, previous, "the initially healthy client still has its older pending interaction")
    assert(w.nodes[A].core.healthy)
    w:pump(25)
    for _, n in pairs(w.nodes) do
        eq(n.core.active.key, current, "an earlier live conflict cannot permanently block later recovery")
        eq(n.core.active.ruleID, "a452")
    end
    w:ready(); w:chatCount(4)
    eq(w.chats[#w.chats].sender, A, "the actual leader announces readiness after catching up")
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
