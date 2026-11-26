-- Runs settings controls and the real event adapter with simulated public APIs.
local client = assert(loadfile("tests/client.lua"))()
local passed, checks = 0, 0
local function expect(value, message) checks = checks + 1; assert(value, message) end
local function test(name, fn)
    local ok, err = pcall(fn)
    assert(ok, name .. ": " .. tostring(err))
    passed = passed + 1
end
local function frame(c, name)
    for _, f in ipairs(c.frames) do if f.name == name then return f end end
end
local function descendant(f, parent)
    while f and type(f) == "table" do
        if f == parent then return true end
        f = rawget(f, "parent")
    end
    return false
end
local function button(c, parent, text)
    for _, f in ipairs(c.frames) do
        local label = type(f.text) == "string" and f.text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        if f.kind == "Button" and label == text and descendant(f, parent) then return f end
    end
    error("Missing button: " .. text)
end
local function click(f)
    expect(f and type(f.scripts.OnClick) == "function", "control must be interactive")
    f.scripts.OnClick(f)
end
local function toggle(f, value) f:SetChecked(value); click(f) end
local function text(c, parent)
    local parts = {}
    for _, f in ipairs(c.frames) do
        if type(f.text) == "string" and descendant(f, parent) then parts[#parts + 1] = f.text end
    end
    return table.concat(parts, "\n")
end
local function slash(c, command) c.env.SlashCmdList.ZKIRPARTYQUESTING(command or "") end
local function settings(c)
    slash(c)
    local f = frame(c, "ZKIRPartyQuestingSettingsWindow")
    expect(f and f:IsShown(), "/zkir must always show settings")
    return f
end
local function warning(c) return frame(c, "ZKIRPartyQuestingWindow") end
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}; for key, item in pairs(value) do result[key] = copy(item) end
    return result
end
local function equal(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for key, value in pairs(a) do if not equal(value, b[key]) then return false end end
    for key in pairs(b) do if a[key] == nil then return false end end
    return true
end

test("idle command opens versioned loaded status with no party activity", function()
    local c = client({party = true})
    local f = settings(c)
    local content = text(c, f)
    expect(content:find("v" .. c.env.C_AddOns.GetAddOnMetadata("ZKIRPartyQuesting", "Version"), 1, true) and
        content:find("Loaded", 1, true), "show actual TOC version")
    expect(content:find("Waiting for a supported interaction", 1, true), "show explicit idle state")
    expect(c.ns.Settings.values.sound == true and c.ns.Settings.values.solo == true and
        c.ns.Settings.values.size == "Normal", "defaults should be sound, solo, normal size")
    expect(frame(c, "ZKIRPartyQuestingSoundCheckbox"):GetChecked() == true, "sound checked by default")
    expect(frame(c, "ZKIRPartyQuestingSoloCheckbox"):GetChecked() == true, "solo checked by default")
    c.advance(30)
    expect(not c.ns.engine.active and #c.messages == 0 and #c.sounds == 0, "idle settings must stay local")
    f:Hide(); slash(c, " settings "); expect(f:IsShown(), "settings alias reopens window")
    f:Hide(); slash(c, "show"); expect(f:IsShown(), "show with no interaction opens settings")
end)

test("controls persist across reload and validate corrupt saved settings", function()
    local c = client(); local f = settings(c)
    toggle(frame(c, "ZKIRPartyQuestingSoundCheckbox"), false)
    toggle(frame(c, "ZKIRPartyQuestingSoloCheckbox"), false)
    click(button(c, f, "Large"))
    local db = c.env.ZKIRPartyQuestingDB
    expect(db.settings.sound == false and db.settings.solo == false and db.settings.size == "Large",
        "control changes must update saved settings")
    local reloaded = client({db = db}); settings(reloaded)
    expect(reloaded.ns.Settings.values.sound == false and reloaded.ns.Settings.values.solo == false and
        reloaded.ns.Settings.values.size == "Large", "reload preserves choices")
    expect(frame(reloaded, "ZKIRPartyQuestingSoundCheckbox"):GetChecked() == false and
        frame(reloaded, "ZKIRPartyQuestingSoloCheckbox"):GetChecked() == false, "controls match persisted values")
    for _, saved in ipairs({"broken", {sound = "false", solo = 0, size = "Huge"}}) do
        local corrupt = client({db = {settings = saved}}); settings(corrupt)
        expect(corrupt.ns.Settings.values.sound == true and corrupt.ns.Settings.values.solo == true and
            corrupt.ns.Settings.values.size == "Normal", "invalid values use safe defaults")
    end
    local corrupt = client({db = "broken"}); settings(corrupt)
    expect(type(corrupt.env.ZKIRPartyQuestingDB) == "table", "invalid saved root is repaired")
end)

test("preview is a local sample without confirmation controls", function()
    local c = client({party = true}); local f = settings(c)
    click(button(c, f, "Preview warning"))
    local preview = frame(c, "ZKIRPartyQuestingPreviewWindow")
    expect(preview and preview:IsShown(), "preview window is visible")
    local content = text(c, preview):lower()
    expect(content:find("preview", 1, true) and content:find("sample", 1, true), "preview must be explicitly labelled")
    for _, state in ipairs({"ready", "not ready", "waiting", "unknown"}) do
        expect(content:find(state, 1, true), "preview demonstrates " .. state)
    end
    local hasConfirmation = false
    for _, child in ipairs(c.frames) do
        if descendant(child, preview) and child.kind == "Button" and
            (child.text == "Ready" or child.text == "Not ready") then hasConfirmation = true end
    end
    expect(not hasConfirmation, "preview must not offer real confirmation")
    expect(not c.ns.engine.active and #c.messages == 0 and #c.sounds == 0, "preview cannot begin coordination")
    click(button(c, f, "Preview warning")); c.advance(20)
    expect(not c.ns.engine.active and #c.messages == 0 and #c.sounds == 0, "repeat preview stays local")
end)

test("preview cannot change an existing event or its evidence", function()
    local c = client({party = true}); c.event("QUEST_DETAIL"); c.advance(8)
    local core = c.ns.engine
    local before = copy({active = core.active, manual = core.manual, facts = core.facts,
        peers = core.peers, saved = core.saved, localFact = core.localFact, hiddenKey = c.ns.UI.hiddenKey})
    local messages, sounds = #c.messages, #c.sounds
    local f = settings(c); click(button(c, f, "Preview warning"))
    expect(equal(before, {active = core.active, manual = core.manual, facts = core.facts,
        peers = core.peers, saved = core.saved, localFact = core.localFact, hiddenKey = c.ns.UI.hiddenKey}),
        "preview and settings must not alter protocol or evidence")
    expect(#c.messages == messages and #c.sounds == sounds, "preview sends no messages or sound")
    expect(warning(c):IsShown(), "real warning remains available alongside preview")
    click(button(c, frame(c, "ZKIRPartyQuestingPreviewWindow"), "X"))
    expect(warning(c):IsShown() and not core.active.started, "closing preview cannot retire the real event")
end)

test("solo switch suppresses automatic presentation without suppressing party coordination", function()
    local c = client({db = {settings = {solo = false}}})
    local f = settings(c); click(button(c, f, "Preview warning"))
    local preview = frame(c, "ZKIRPartyQuestingPreviewWindow")
    c.event("QUEST_DETAIL"); c.advance(8)
    expect(not warning(c) or not warning(c):IsShown(), "disabled solo warnings stay hidden")
    expect(preview:IsShown(), "suppressed solo warning does not dismiss preview")
    expect(#c.sounds == 0 and #c.messages == 0, "hidden solo attempt is silent")
    c.options.party = true; c.event("GROUP_ROSTER_UPDATE"); c.advance(6)
    expect(warning(c):IsShown(), "joining a party presents the event even with solo disabled")
    expect(not preview:IsShown() and (rawget(warning(c), "raised") or 0) > 0,
        "newly visible party coordination takes priority over the sample")
    expect(#c.sounds == 0, "showing an existing attempt after regrouping does not replay audio")
    expect(#c.ns.engine:rows() == 2 and #c.messages > 0, "party protocol remains active")
    expect(c.ns.engine:rows()[2].status == "Unknown", "silent party member remains unverified")
    local explicit = client({db = {settings = {solo = false}}})
    explicit.event("QUEST_DETAIL"); slash(explicit, "show")
    expect(warning(explicit):IsShown(), "explicit show can open a solo warning")
    expect(#explicit.sounds == 0, "explicit reopening must not play warning sound")
end)

test("turning off solo presentation during an active solo event hides it", function()
    local c = client(); c.event("QUEST_DETAIL")
    local f = settings(c); local key = c.ns.engine.active.key
    toggle(frame(c, "ZKIRPartyQuestingSoloCheckbox"), false)
    expect(not warning(c):IsShown(), "switch takes effect immediately")
    expect(c.ns.engine.active.key == key and not c.ns.engine.active.started, "settings do not retire the event")
    toggle(frame(c, "ZKIRPartyQuestingSoloCheckbox"), true)
    expect(warning(c):IsShown() and #c.sounds == 1, "presentation changes do not duplicate audio")
    expect(f:IsShown(), "settings remain open while changing them")
end)

test("a hidden solo attempt still announces once after joining a party", function()
    local c = client({db = {settings = {solo = false}}})
    c.event("QUEST_DETAIL"); c.advance(30)
    expect(#c.messages == 0, "solo coordination sends no chat or addon messages")
    local key = c.ns.engine.active.key
    c.options.party = true; c.event("GROUP_ROSTER_UPDATE"); c.advance(30)
    expect(c.ns.engine.active.key == key, "regrouping keeps the existing attempt")
    local initial, nextAction = 0, 0
    local rule = c.ns.Rules[c.ns.engine.active.ruleID]
    for _, message in ipairs(c.messages) do
        if message.chat == "ZKIR: " .. c.ns.Messages.chatWarning(rule) then initial = initial + 1 end
        if message.chat == "ZKIR: " .. c.ns.Messages.chatNext(rule) then nextAction = nextAction + 1 end
    end
    expect(initial == 1, "joining a party must send exactly one initial warning")
    expect(nextAction == 0 and not c.ns.engine:allReady(), "nonresponder prevents permission to proceed")
    c.event("GROUP_ROSTER_UPDATE"); c.advance(20)
    local total = 0; for _, message in ipairs(c.messages) do if message.chat then total = total + 1 end end
    expect(total == 1, "repeated roster updates do not duplicate the initial warning")
end)

test("sound plays once per new visible attempt, never per tick or manual reopening", function()
    local c = client(); c.event("QUEST_DETAIL")
    expect(#c.sounds == 1, "new warning plays one sound")
    c.advance(15); c.event("QUEST_DETAIL"); slash(c, "show")
    expect(#c.sounds == 1, "polling and repeated detection do not repeat audio")
    click(button(c, warning(c), "X")); c.advance(3); slash(c, "show")
    expect(#c.sounds == 1, "closing and reopening do not repeat audio")
    local key = c.ns.engine.active.key; slash(c, "retry")
    expect(c.ns.engine.active.key ~= key and #c.sounds == 2, "new retry has one fresh sound")
    c.advance(10); expect(#c.sounds == 2, "retry updates stay silent")
end)

test("sound preference applies immediately and safely handles unavailable sound APIs", function()
    local c = client(); local f = settings(c)
    toggle(frame(c, "ZKIRPartyQuestingSoundCheckbox"), false)
    c.event("QUEST_DETAIL"); c.advance(8); expect(#c.sounds == 0, "disabled audio remains silent")
    toggle(frame(c, "ZKIRPartyQuestingSoundCheckbox"), true)
    c.advance(4); expect(#c.sounds == 0, "enabling sound does not replay the existing attempt")
    slash(c, "retry"); expect(#c.sounds == 1, "subsequent attempt uses new preference")
    for _, options in ipairs({{missingSound = true}, {throwSound = true}}) do
        local unavailable = client(options); unavailable.event("QUEST_DETAIL"); unavailable.advance(10)
        expect(warning(unavailable):IsShown() and unavailable.ns.engine:allReady(), "audio failure cannot break readiness")
        expect(#unavailable.sounds <= 1, "failed sound is not retried on each update")
    end
    local modern = client()
    local calls = 0
    modern.env.C_Sound = {PlaySound = function(id) calls = calls + 1; expect(type(id) == "number", "sound uses a public sound kit") end}
    modern.event("QUEST_DETAIL"); modern.advance(10)
    expect(calls == 1 and #modern.sounds == 0, "Forever C_Sound is preferred without duplicate legacy playback")
    local failed = client(); calls = 0
    failed.env.C_Sound = {PlaySound = function() calls = calls + 1; error("Sound unavailable") end}
    failed.event("QUEST_DETAIL"); failed.advance(10)
    expect(warning(failed):IsShown() and failed.ns.engine:allReady(), "modern sound failure cannot break warnings")
    expect(calls == 1 and #failed.sounds == 0, "failed modern playback is neither retried nor duplicated")
    expect(f:IsShown(), "changing audio does not dismiss settings")
end)

test("restored attempts and concurrent event aliases do not replay sound", function()
    local original = client(); original.event("QUEST_DETAIL"); original.advance(8)
    expect(#original.sounds == 1, "original event sounds once")
    local restored = client({db = copy(original.env.ZKIRPartyQuestingDB)})
    expect(restored.ns.engine.active and warning(restored):IsShown(), "saved event returns after reload")
    restored.advance(10); slash(restored, "show")
    expect(#restored.sounds == 0, "reload never sounds a saved attempt again")

    local c = client({party = true}); c.event("QUEST_DETAIL")
    local a = c.ns.engine.active
    local canonical = "1000.1000.0.1.1"
    expect(canonical < a.key, "fixture uses the lower canonical key")
    local payload = table.concat({"1", "E", canonical, a.parent, a.ruleID, a.context, tostring(a.time), "0"}, "|")
    c.event("CHAT_MSG_ADDON", "ZKIRPQ1", payload, "PARTY", "Bob-Realm")
    expect(c.ns.engine.active.key == a.key, "unconfirmed event aliases cannot replace the current attempt")
    local token
    for _, message in ipairs(c.messages) do
        if message.data then
            local key, value = message.data:match("^1|V|([^|]+)|([^|]+)$")
            if key == canonical then token = value end
        end
    end
    expect(token, "alias reconciliation must issue a live challenge")
    c.event("CHAT_MSG_ADDON", "ZKIRPQ1", table.concat({"1", "Y", canonical, token, "0"}, "|"), "PARTY", "Bob-Realm")
    expect(c.ns.engine.active.key == canonical, "network event alias must actually converge")
    c.advance(8)
    expect(#c.sounds == 1, "concurrent detections have one audible warning")
end)

test("a new real event dismisses and raises over preview without periodic raising", function()
    local c = client(); local f = settings(c)
    click(button(c, f, "Preview warning"))
    local preview = frame(c, "ZKIRPartyQuestingPreviewWindow")
    expect(preview:IsShown(), "preview begins visible")
    c.event("QUEST_DETAIL")
    expect(not preview:IsShown() and warning(c):IsShown(), "real coordination takes priority over samples")
    local raised = rawget(warning(c), "raised") or 0
    expect(raised > 0, "new real warning is brought forward")
    c.advance(10)
    expect(warning(c).raised == raised, "periodic updates must not steal window focus")
end)

test("size and reset affect all three windows without protocol changes", function()
    local c = client(); local f = settings(c)
    c.event("QUEST_DETAIL"); click(button(c, f, "Preview warning"))
    local windows = {f, warning(c), frame(c, "ZKIRPartyQuestingPreviewWindow")}
    local defaults = {}; for i, window in ipairs(windows) do defaults[i] = copy(window.point) end
    local key, sounds = c.ns.engine.active.key, #c.sounds
    for _, choice in ipairs({{"Small", 0.85}, {"Normal", 1}, {"Large", 1.15}}) do
        click(button(c, f, choice[1]))
        expect(c.ns.Settings.values.size == choice[1] and c.ns.Settings.sizeScale() == choice[2], "size selection persisted")
        for _, window in ipairs(windows) do expect(window:GetScale() == choice[2], "size reaches every window") end
    end
    for _, window in ipairs(windows) do window:SetPoint("TOPLEFT", c.env.UIParent, "TOPLEFT", 900, -900) end
    click(button(c, f, "Reset window position"))
    for i, window in ipairs(windows) do expect(equal(window.point, defaults[i]), "reset restores default anchor") end
    expect(c.ns.engine.active.key == key and #c.messages == 0 and #c.sounds == sounds,
        "size and position changes cannot affect event or sound")
end)

test("settings remain usable when player identity prevents initialization", function()
    local c = client({missingIdentity = true}); local f = settings(c)
    expect(not c.ns.engine, "identity failure prevents engine initialization")
    expect(text(c, f):find("player identity is unavailable", 1, true), "failure is visible in settings")
    click(button(c, f, "Preview warning"))
    expect(frame(c, "ZKIRPartyQuestingPreviewWindow"):IsShown() and #c.messages == 0, "preview works before engine initialization")
    c.options.missingIdentity = false; c.event("PLAYER_ENTERING_WORLD")
    expect(c.ns.engine and text(c, f):find("Waiting for a supported interaction", 1, true), "status refreshes after recovery")
end)

test("open status tracks event and messaging health", function()
    local c = client({party = true}); local f = settings(c)
    c.event("QUEST_DETAIL")
    expect(text(c, f):find("Coordinating:", 1, true), "status changes when interaction is detected")
    c.options.locked = true; c.advance(1)
    expect(text(c, f):find("Party messaging is restricted", 1, true), "lockdown is shown promptly")
    c.options.locked = false; c.advance(1)
    expect(not text(c, f):find("Party messaging is restricted", 1, true), "status refreshes when restriction lifts")
    local unavailable = client({party = true, registration = 2}); f = settings(unavailable)
    expect(text(unavailable, f):find("Party messaging is unavailable", 1, true), "failed prefix registration is explicit while idle")
    unavailable.event("QUEST_DETAIL"); unavailable.advance(15)
    expect(not unavailable.ns.engine:allReady(), "settings cannot bypass missing communication")
    local noChat = client({party = true}); noChat.env.C_ChatInfo.SendChatMessage = nil
    f = settings(noChat)
    expect(text(noChat, f):find("Party chat is unavailable", 1, true), "missing chat API is visible before an interaction")
end)

test("hidden settings wait to render the latest state until reopened", function()
    local c = client({party = true}); local f = settings(c)
    f:Hide()
    local writes = {}
    for _, child in ipairs(c.frames) do
        if descendant(child, f) then writes[child] = child.textWrites or 0 end
    end
    c.event("QUEST_DETAIL"); c.advance(6)
    for child, count in pairs(writes) do
        expect((child.textWrites or 0) == count, "closed settings must not redraw during coordination")
    end
    slash(c)
    expect(f:IsShown() and text(c, f):find("Coordinating:", 1, true), "opening settings displays current event status")
end)

test("visible settings redraw only when displayed state or a setting changes", function()
    local c = client(); local f = settings(c)
    local function writes()
        local total = 0
        for _, child in ipairs(c.frames) do
            if descendant(child, f) then total = total + (child.textWrites or 0) end
        end
        return total
    end
    local initial = writes()
    c.advance(6); c.ns.Settings.refresh()
    expect(writes() == initial, "unchanged open settings must not rewrite text during polling")
    c.event("QUEST_DETAIL")
    expect(writes() > initial and text(c, f):find("Coordinating:", 1, true), "new event status renders immediately")
    local statusWrites = writes()
    c.advance(8)
    expect(writes() == statusWrites, "unchanged event status stays cached across readiness updates")
    click(button(c, f, "Small"))
    expect(writes() > statusWrites and f:GetScale() == 0.85 and
        button(c, f, "Small").text == "|cffffd160Small|r", "actual setting change refreshes the selection and scale")
    local settingWrites = writes()
    c.advance(3); c.ns.Settings.refresh()
    expect(writes() == settingWrites, "new setting becomes the stable cached presentation")
end)

test("auto FFA adds exactly two options and both default off", function()
    local c = client(); local f = settings(c)
    expect(c.ns.AutoLoot and type(c.ns.AutoLoot.setCharacters) == "function", "production loot module must load from the TOC")
    expect(c.ns.Settings.values.ffaFriends == false and c.ns.Settings.values.ffaCharacters == false,
        "new loot policies are opt-in")
    expect(frame(c, "ZKIRPartyQuestingFFAFriendsCheckbox"):GetChecked() == false and
        frame(c, "ZKIRPartyQuestingFFACharactersCheckbox"):GetChecked() == false,
        "both new controls visibly start unchecked")
    local checkboxes = 0
    for _, child in ipairs(c.frames) do
        if child.kind == "CheckButton" and descendant(child, f) then checkboxes = checkboxes + 1 end
    end
    expect(checkboxes == 4, "sound and solo plus exactly two loot checkboxes")
    expect(text(c, f):find("every other member", 1, true) and text(c, f):find("either enabled option", 1, true)
        and text(c, f):find("dungeons use Group Loot", 1, true),
        "explain dungeon priority and outdoor trust requirements")
    expect(text(c, f):find("Auto FFA is off.", 1, true), "off state is explicit")
    local corrupt = client({db = {settings = {ffaFriends = "true", ffaCharacters = 1}}})
    settings(corrupt)
    expect(corrupt.ns.Settings.values.ffaFriends == false and corrupt.ns.Settings.values.ffaCharacters == false,
        "invalid persisted loot flags must fail closed")
    expect(#c.messages == 0 and #c.sounds == 0, "opening loot settings must not create party activity")
end)

test("loot toggles are independent, persisted, and notify the runtime", function()
    local c = client(); settings(c)
    local updates = 0
    local original = c.ns.AutoLoot.settingsChanged
    c.ns.AutoLoot.settingsChanged = function(...)
        updates = updates + 1
        return original(...)
    end
    toggle(frame(c, "ZKIRPartyQuestingFFAFriendsCheckbox"), true)
    expect(c.env.ZKIRPartyQuestingDB.settings.ffaFriends == true and
        c.env.ZKIRPartyQuestingDB.settings.ffaCharacters == false, "friend toggle leaves character choice unchanged")
    expect(updates == 1, "friend toggle reaches the production runtime immediately")
    toggle(frame(c, "ZKIRPartyQuestingFFACharactersCheckbox"), true)
    expect(updates == 2 and c.env.ZKIRPartyQuestingDB.settings.ffaCharacters == true,
        "character toggle persists and reaches the runtime")
    toggle(frame(c, "ZKIRPartyQuestingFFAFriendsCheckbox"), false)
    expect(updates == 3 and c.env.ZKIRPartyQuestingDB.settings.ffaCharacters == true,
        "either option can be switched off independently")
    local reloaded = client({db = copy(c.env.ZKIRPartyQuestingDB)}); settings(reloaded)
    expect(frame(reloaded, "ZKIRPartyQuestingFFAFriendsCheckbox"):GetChecked() == false and
        frame(reloaded, "ZKIRPartyQuestingFFACharactersCheckbox"):GetChecked() == true,
        "reload preserves each loot option and its visible state")
    expect(#c.messages == 0, "loot preferences never send party messages")
end)

local function characters(c)
    local f = settings(c)
    click(button(c, f, "Characters..."))
    local editor = frame(c, "ZKIRPartyQuestingCharactersWindow")
    local input = frame(c, "ZKIRPartyQuestingCharactersText")
    expect(editor and editor:IsShown() and input, "character editor opens with a text field")
    return editor, input
end

test("character Save uses the real validator and never enables auto FFA", function()
    local c = client(); local editor, input = characters(c)
    input:SetText("  Bob \r\nCara-Other Realm\n\nbob-Realm\n")
    click(button(c, editor, "Save"))
    expect(not editor:IsShown(), "successful Save closes the editor")
    expect(equal(c.env.ZKIRPartyQuestingDB.settings.ffaNames, {['bob-realm'] = true, ['cara-otherrealm'] = true}),
        "Save resolves current-realm names, normalizes realms, and deduplicates through AutoLoot")
    expect(c.ns.Settings.values.ffaFriends == false and c.ns.Settings.values.ffaCharacters == false,
        "saving a character list cannot opt into either loot policy")
    local reloaded = client({db = copy(c.env.ZKIRPartyQuestingDB)})
    local _, restored = characters(reloaded)
    expect(restored:GetText() == "bob-realm\ncara-otherrealm", "saved names survive reload and reopen in stable order")
    expect(#c.messages == 0 and #c.sounds == 0, "editing the allowlist is local and silent")
end)

test("invalid character input and cancelled drafts never partially change the allowlist", function()
    local c = client(); expect(c.ns.AutoLoot.setCharacters("Bob-Realm"), "seed a real existing character list")
    local previous = c.env.ZKIRPartyQuestingDB.settings.ffaNames
    local before = copy(previous)
    local editor, input = characters(c)
    local invalid = "Cara-Realm\nBad Name"
    input:SetText(invalid); click(button(c, editor, "Save"))
    expect(editor:IsShown() and input:GetText() == invalid, "validation failure keeps the draft editable")
    expect(text(c, editor):find("Use Name-Realm", 1, true), "validation error is visible to the user")
    expect(c.env.ZKIRPartyQuestingDB.settings.ffaNames == previous and equal(previous, before),
        "a valid first line must not partially replace the old list when a later line is invalid")
    input:SetText("Dain-Realm"); click(button(c, editor, "Cancel"))
    expect(not editor:IsShown() and equal(c.ns.Settings.values.ffaNames, before), "Cancel discards the entire draft")
    editor, input = characters(c)
    expect(input:GetText() == "bob-realm", "reopening discards cancelled text")
    input:SetText("Elya-Realm")
    expect(type(input.scripts.OnEscapePressed) == "function", "editor supports Escape")
    input.scripts.OnEscapePressed(input)
    expect(not editor:IsShown() and equal(c.ns.Settings.values.ffaNames, before), "Escape cannot commit a draft")
end)

test("loot status refreshes without overwriting an open character draft", function()
    local c = client(); local editor, input = characters(c)
    local f = frame(c, "ZKIRPartyQuestingSettingsWindow")
    input:SetText("Unsubmitted-Realm")
    c.ns.AutoLoot.status = function() return "Waiting until the party is out of combat." end
    c.ns.Settings.refresh()
    expect(text(c, f):find("Waiting until the party is out of combat.", 1, true), "show the runtime's current loot status")
    expect(editor:IsShown() and input:GetText() == "Unsubmitted-Realm", "status updates preserve the user's editor draft")
    c.ns.AutoLoot.status = function() error("unavailable") end
    c.ns.Settings.refresh()
    expect(text(c, f):find("Auto FFA is unavailable.", 1, true), "status failure is explicit and does not break settings")
    expect(input:GetText() == "Unsubmitted-Realm" and next(c.ns.Settings.values.ffaNames) == nil,
        "status failures neither replace nor save the draft")
end)

print("Settings simulations passed: " .. passed .. " scenarios, " .. checks .. " checks.")
