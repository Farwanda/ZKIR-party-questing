-- Geometry and lifecycle simulations using the real TOC. These are not rendered game checks.
local client = assert(loadfile("tests/client.lua"))()
local passed, checks = 0, 0
local function expect(value, message) checks = checks + 1; assert(value, message) end
local function test(name, fn)
    local ok, err = pcall(fn)
    assert(ok, name .. ": " .. tostring(err))
    passed = passed + 1
end
local function descendant(frame, parent)
    while frame do
        if frame == parent then return true end
        frame = frame.parent
    end
    return false
end
local function text(c, parent)
    local result = {}
    for _, frame in ipairs(c.frames) do
        if frame:IsVisible() and descendant(frame, parent) and type(frame.text) == "string" then
            result[#result + 1] = frame.text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        end
    end
    return table.concat(result, "\n")
end
local function warning(c) return c.env.ZKIRPartyQuestingWindow end
local function anchor(c) local _, relative = warning(c):GetPoint(); return relative end
local function showQuest(c, id)
    c.setQuest(id or 7046); c.env.QuestFrame:Show(); c.event("QUEST_DETAIL")
end
local function buttons(c, parent, label)
    local found = {}
    for _, frame in ipairs(c.frames) do
        if frame.kind == "Button" and frame.text == label and frame:IsVisible() and descendant(frame, parent) then
            found[#found + 1] = frame
        end
    end
    return found
end
local function click(frame)
    expect(frame and frame.scripts.OnClick, "expected an interactive control")
    frame.scripts.OnClick(frame)
end
local function remote(c, context)
    local payload = table.concat({"1", "E", "1000.remote.1", "0", "a7046", context or "Creature-0-1-1-1-13716-0001", "1000", "0"}, "|")
    c.event("CHAT_MSG_ADDON", "ZKIRPQ1", payload, "PARTY", "Bob-Realm")
end

test("matching quest attaches before acceptance and closure keeps coordination open", function()
    local c = client({party = true}); showQuest(c)
    local panel, key = warning(c), c.ns.engine.active.key
    expect(panel:IsShown() and panel:GetWidth() == 340, "pre-action window is compact and synchronous")
    expect(anchor(c) == c.env.QuestFrame, "matching quest anchors to the native dialogue")
    expect(c.env.QuestFrame:IsShown(), "addon must preserve the native quest window")
    c.env.QuestFrame:Hide(); c.event("QUEST_FINISHED")
    expect(panel:IsShown() and anchor(c) == c.env.UIParent, "closing dialogue moves unresolved panel to fallback")
    expect(c.ns.engine.active.key == key and not c.ns.engine.active.started, "dialogue closure is not a quest action")
    showQuest(c)
    expect(anchor(c) == c.env.QuestFrame and c.ns.engine.active.key == key, "reopening same dialogue reattaches existing attempt")
end)

test("remote recipients use fallback unless their open dialogue matches the event", function()
    local c = client({party = true}); remote(c)
    expect(warning(c):IsShown() and anchor(c) == c.env.UIParent, "remote client sees automatic fallback without NPC dialogue")
    expect(not c.env.QuestFrame:IsShown() and not c.env.GossipFrame:IsShown(), "sync cannot open game dialogue")
    showQuest(c, 99999)
    expect(anchor(c) == c.env.UIParent, "unrelated quest must not host remote coordination")
    showQuest(c, 7046)
    expect(anchor(c) == c.env.QuestFrame, "same quest and NPC can attach the remote attempt")
    local other = client({party = true, guid = "Creature-0-1-1-1-13716-9999"})
    showQuest(other, 99999); remote(other)
    other.setQuest(7046)
    other.env.QuestFrame:Hide(); other.env.QuestFrame:Show()
    expect(anchor(other) == other.env.UIParent, "same quest at a different NPC instance must not inherit the event anchor")
end)

test("gossip offer follows the matching quest transition without replacing the event", function()
    local c = client({guid = "Creature-0-1-1-1-9623-0001", party = true})
    c.env.C_GossipInfo.GetAvailableQuests = function() return {{questID = 4245}} end
    c.env.GossipFrame:Show(); c.event("GOSSIP_SHOW")
    local key = c.ns.engine.active.key
    expect(anchor(c) == c.env.GossipFrame, "hazardous available quest attaches to gossip")
    c.env.GossipFrame:Hide(); c.event("GOSSIP_CLOSED"); showQuest(c, 4245)
    expect(anchor(c) == c.env.QuestFrame and c.ns.engine.active.key == key, "same NPC offer moves to quest dialogue")
    expect(not c.ns.engine.active.started, "selecting a quest offer must not count as accepting it")
end)

test("both native gossip selection paths use captured context and retire once", function()
    for _, method in ipairs({"SelectOption", "SelectOptionByIndex"}) do
        local c = client({party = true, guid = "Creature-0-1-1-1-6669-0001"})
        c.env.GossipFrame:Show(); c.event("GOSSIP_SHOW"); c.advance(6)
        local panel, oldHeight = warning(c), warning(c):GetHeight()
        expect(type(c.hooks[method]) == "function", "native path needs a posthook: " .. method)
        c.options.selectGossip = function()
            c.env.GossipFrame:Hide(); c.options.guid = "Creature-0-1-1-1-9999-0001"
            c.event("GOSSIP_CLOSED")
        end
        c.env.C_GossipInfo[method](123)
        expect(c.ns.engine.active.started and not c.ns.engine:allReady(), "selection retires captured dialogue despite native cleanup")
        expect(panel:IsShown() and panel:GetHeight() < oldHeight, "observed action collapses the panel")
        expect(text(c, panel):find("CHOICE MADE", 1, true), "collapsed panel reports selection without claiming the event started")
        expect(#buttons(c, panel, "Check") == 0, "started panels cannot offer confirmation")
        local count = #c.messages
        c.hooks.SelectOption(123); c.hooks.SelectOptionByIndex(1)
        expect(#c.messages == count, "overlapping hooks must not duplicate action broadcasts")
    end
end)

test("gossip callbacks without matching captured dialogue cannot start another event", function()
    local c = client({party = true}); showQuest(c)
    c.hooks.SelectOption(123); c.hooks.SelectOptionByIndex(1)
    expect(not c.ns.engine.active.started, "arbitrary gossip selection cannot retire an acceptance event")
    c.options.guid = "Creature-0-1-1-1-6669-0001"
    c.env.GossipFrame:Show(); c.event("GOSSIP_SHOW")
    c.options.guid = "Creature-0-1-1-1-9999-0001"; c.event("GOSSIP_SHOW")
    c.hooks.SelectOptionByIndex(1)
    expect(not c.ns.engine.active.started, "a later unrelated conversation invalidates old dialogue selection context")
end)

test("quest invitations and remote actions never claim local acceptance", function()
    for _, observation in ipairs({"invite", "remote", "remote then invite"}) do
        local c = client({party = true}); showQuest(c); c.advance(6)
        local panel, key = warning(c), c.ns.engine.active.key
        expect(c.state[7046].active == false and #buttons(c, panel, "Check") == 1,
            "fixture has no local acceptance and still needs party confirmation")
        if observation ~= "invite" then
            c.event("CHAT_MSG_ADDON", "ZKIRPQ1", "1|X|" .. key, "PARTY", "Bob-Realm")
        end
        if observation ~= "remote" then
            c.event("QUEST_ACCEPT_CONFIRM", "Bob", "Untrusted title", 7046)
        end
        local content = text(c, panel)
        expect(c.ns.engine.active.started and not c.ns.engine:allReady(), "observed party action retires readiness")
        expect(content:find("ACTION TAKEN", 1, true) and not content:find("QUEST ACCEPTED", 1, true),
            "collapsed text cannot claim the local player accepted")
        expect(c.state[7046].active == false, "observation must not mutate local quest state")
        expect(#buttons(c, panel, "Check") == 0 and #buttons(c, panel, "Ready") == 0 and
            not content:find("ALL READY", 1, true), "collapsed panel cannot offer stale preparation or permission")
        if observation ~= "remote" then
            expect(content:find("invite received", 1, true) and content:find("game prompt", 1, true),
                "the invitation instruction remains visible before the user accepts")
        end
    end
end)

test("compact panel sizes to actual solo and two-to-five player rosters", function()
    local heights = {}
    for count = 1, 5 do
        local members = {player = {name = "Alexandrianna", realm = "VeryLongRealm"}}
        for i = 1, count - 1 do members["party" .. i] = {name = "Companion" .. i, realm = "AnotherLongRealm"} end
        local c = client({party = count - 1, members = members}); showQuest(c); c.advance(6)
        local panel, content = warning(c), text(c, warning(c))
        heights[count] = panel:GetHeight()
        expect(panel:GetWidth() == 340 and #c.ns.engine:rows() == count, "actual party controls compact row count")
        expect(content:find("Alexandrianna", 1, true), "long local name stays identifiable")
        for i = 1, count - 1 do expect(content:find("Companion" .. i, 1, true), "every current member remains visible") end
        local fullNameVisible = false
        for _, frame in ipairs(c.frames) do
            if frame:IsVisible() and descendant(frame, panel) and frame.scripts.OnEnter then
                frame.scripts.OnEnter(frame)
                if c.env.GameTooltip:GetText():find("Alexandrianna-VeryLongRealm", 1, true) then fullNameVisible = true end
                frame.scripts.OnLeave(frame)
            end
        end
        expect(fullNameVisible and not c.env.GameTooltip:IsShown(), "hover provides full identity and closes normally")
        expect(heights[count] < 500, "normal compact panel stays below 500 UI units")
    end
    for count = 2, 5 do expect(heights[count] > heights[count - 1], "no reserved blank roster rows") end
end)

test("anchoring chooses screen room and respects warning scale", function()
    local c = client({screenWidth = 1000}); showQuest(c)
    expect(anchor(c) == c.env.QuestFrame and warning(c):GetLeft() >= c.env.QuestFrame:GetRight(),
        "panel starts beside the quest when room is available")
    c.env.QuestFrame:ClearAllPoints(); c.env.QuestFrame:SetPoint("TOPRIGHT", c.env.UIParent, "TOPRIGHT", -20, -80)
    c.ns.UI.setAnchor(c.env.QuestFrame)
    expect(warning(c):GetRight() <= c.env.QuestFrame:GetLeft(), "near right screen edge the panel uses the left side")
    c.ns.Settings.values.size = "Large"; c.ns.UI.applySettings()
    expect(warning(c):GetScale() == 1.15 and anchor(c) == c.env.QuestFrame, "size preference preserves attachment")
    expect(c.env.QuestFrame:GetScale() == 1, "scaling the addon never resizes native controls")
end)

test("leader confirmations are compact, distinct, and cannot override new blockers", function()
    local c = client({party = true}); showQuest(c); c.advance(6)
    local panel = warning(c)
    expect(#buttons(c, panel, "Ready") == 0 and #buttons(c, panel, "Not ready") == 0,
        "confirmation choices stay hidden until needed")
    expect(#buttons(c, panel, "Check") == 1, "only the unknown party member has a leader check")
    click(buttons(c, panel, "Check")[1]); local ready = buttons(c, panel, "Ready")[1]
    click(ready)
    expect(c.ns.engine:rows()[2].source == "leader" and text(c, panel):find("Leader", 1, true),
        "manual confirmation stays distinct from automatic evidence")
    click(buttons(c, panel, "Check")[1]); ready = buttons(c, panel, "Ready")[1]
    c.options.members = {party1 = {name = "Bob", connected = false}}; c.event("UNIT_CONNECTION", "party1", false)
    click(ready)
    expect(c.ns.engine:rows()[2].status == "Not Ready" and not c.ns.engine.manual["Bob-Realm"],
        "stale control cannot conceal disconnection")
    expect(#buttons(c, panel, "Check") == 0, "verified blockers have no confirmation control")
    local member = client({party = true, leader = "party1"}); showQuest(member); member.advance(6)
    expect(#buttons(member, warning(member), "Check") == 0, "ordinary members cannot confirm missing information")
end)

test("important blocker fix is visible and details do not replace normal instructions", function()
    local c = client({guid = "Creature-0-1-1-1-9623-0001"})
    c.state[4244] = {active = true, complete = true, rewarded = false}; showQuest(c, 4245); c.advance(6)
    local panel, before = warning(c), text(c, warning(c))
    expect(before:find("WAIT", 1, true) and before:find("Turn in", 1, true), "show the actionable hand-in fix without hover")
    expect(not before:find("confirmation token", 1, true), "routine warning must not expose protocol tokens")
    click(buttons(c, panel, "Details")[1])
    expect(text(c, panel):find("credit", 1, true), "shared details retain the credit limitation")
    expect(text(c, panel):find("WAIT", 1, true), "details keep the main action visible")
end)

test("an open confirmation cannot be reused after retry or a row changes identity", function()
    for _, change in ipairs({"retry", "member"}) do
        local c = client({party = true}); showQuest(c); c.advance(6)
        local panel = warning(c)
        click(buttons(c, panel, "Check")[1]); local ready = buttons(c, panel, "Ready")[1]
        if change == "retry" then
            c.env.SlashCmdList.ZKIRPARTYQUESTING("retry"); c.advance(6)
        else
            c.options.members = {party1 = {name = "Cara"}}; c.event("GROUP_ROSTER_UPDATE")
        end
        click(ready)
        expect(next(c.ns.engine.manual) == nil, "old menu must not confirm after " .. change)
        expect(#buttons(c, panel, "Ready") == 0, "changed context closes confirmation choices")
    end
end)

test("steady polling does not rebuild unchanged visible text", function()
    local c = client(); showQuest(c); c.advance(10)
    local writes = {}
    for _, frame in ipairs(c.frames) do
        if descendant(frame, warning(c)) then writes[frame] = frame.textWrites or 0 end
    end
    c.advance(6)
    for frame, count in pairs(writes) do
        expect((frame.textWrites or 0) == count, "unchanged panel text must not redraw on each tick")
    end
end)

print("Attachment simulations passed: " .. passed .. " scenarios, " .. checks .. " checks.")
