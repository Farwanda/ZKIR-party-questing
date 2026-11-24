local _, NS = ...
local UI = {}
NS.UI = UI
local frame, warning, footer, rows, previewFrame
local observedAttempts = {}
local colors = {Ready = {0.35, 1, 0.45}, ["Not Ready"] = {1, 0.4, 0.35},
    Waiting = {1, 0.85, 0.35}, Unknown = {0.75, 0.75, 0.75}}
local reasons = {NO_RESPONSE = "No addon response", WAITING = "Waiting for addon",
    CONNECTION_UNKNOWN = "Connection state unavailable",
    OFFLINE = "Disconnected", LOG_FULL = "Quest log full", LEVEL = "Below the quest's required level",
    FACTION = "Quest faction does not match", CLASS = "Quest class does not match", RACE = "Quest race does not match",
    ALREADY_REWARDED = "Quest already handed in",
    ALREADY_ACTIVE = "Quest already active; check this attempt", ALREADY_COMPLETE = "Objectives already complete",
    OBJECTIVES_INCOMPLETE = "Finish this quest's objectives before the coordinated hand-in",
    NEED_QUEST = "Accept the quest first", FAILED = "Quest failed", VERIFY_DETAILS = "Leader: verify missing details",
    PREPARED = "Quest preparation checked", LEADER_CONFIRMED = "Confirmed by the actual party leader"}
local function explanation(code)
    local excluded = code and code:match("^EXCLUSIVE_(%d+)$")
    if excluded then return "Conflicting quest #" .. excluded .. " is active or handed in" end
    if code == "VERIFY_DETAILS" and UI.engine and UI.engine.active then
        local rule = NS.Rules[UI.engine.active.ruleID]
        if rule.details then return rule.details end
    end
    local id = code and code:match("^PREREQUISITE_(%d+)$") or code and code:match("^HAND_IN_(%d+)$")
    return id and ("Hand in prerequisite #" .. id) or reasons[code] or "Missing information"
end
local function label(parent, x, y, width)
    local t = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    t:SetPoint("TOPLEFT", x, y)
    t:SetWidth(width)
    t:SetJustifyH("LEFT")
    t:SetJustifyV("TOP")
    return t
end
local function button(parent, text, width, callback)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 20)
    b:SetText(text)
    b:SetScript("OnClick", callback)
    return b
end
local function position(window)
    window:ClearAllPoints()
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
end
local function scale()
    return NS.Settings and NS.Settings.sizeScale() or 1
end
local function createWindow(name)
    local window = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    window:SetSize(470, 338)
    position(window)
    window:SetScale(scale())
    window:SetFrameStrata("DIALOG")
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}})
    window:SetBackdropColor(0.05, 0.05, 0.07, 0.97)
    return window
end
local function attemptID(active)
    -- Concurrent detections converge on a different key but share these fields.
    -- A deliberate retry has the previous key as its parent and is a new warning.
    return table.concat({active.parent or "0", active.ruleID or "", active.context or ""}, "\031")
end
local function create()
    if frame then return end
    frame = createWindow("ZKIRPartyQuestingWindow")
    label(frame, 14, -14, 400):SetText("|cffffd160ZKIR PARTY QUESTING|r")
    local close = button(frame, "X", 22, function()
        local active = UI.engine and UI.engine.active
        UI.hiddenKey = active and active.key
        UI.hiddenAttempt = active and attemptID(active)
        frame:Hide()
    end)
    close:SetPoint("TOPRIGHT", -9, -9)
    warning = label(frame, 14, -40, 442)
    warning:SetHeight(54)
    rows = {}
    for i = 1, 5 do
        local row = {}
        row.text = label(frame, 14, -100 - (i - 1) * 33, 300)
        row.text:SetHeight(31)
        row.hover = CreateFrame("Frame", nil, frame)
        row.hover:SetSize(300, 31)
        row.hover:SetPoint("TOPLEFT", 14, -100 - (i - 1) * 33)
        row.hover:EnableMouse(true)
        row.hover:SetScript("OnEnter", function(self)
            if not row.entry or not GameTooltip then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(row.entry.name)
            GameTooltip:AddLine(explanation(row.entry.reason), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        row.hover:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
        row.yes = button(frame, "Ready", 57, function() UI.engine:confirm(row.name, "R") end)
        row.no = button(frame, "Not ready", 76, function() UI.engine:confirm(row.name, "N") end)
        row.yes:SetPoint("TOPLEFT", 315, -100 - (i - 1) * 33)
        row.no:SetPoint("LEFT", row.yes, "RIGHT", 3, 0)
        rows[i] = row
    end
    footer = label(frame, 14, -271, 442)
    footer:SetHeight(52)
end
function UI.update(engine, presentationOnly)
    UI.engine = engine
    local options = NS.Settings and NS.Settings.values or {}
    UI.lastSolo = options.solo ~= false
    if not engine or not engine.active then if frame then frame:Hide() end; return end
    create()
    local a, data = engine.active, engine:rows()
    local attempt = attemptID(a)
    local firstObservation = not observedAttempts[attempt]
    observedAttempts[attempt] = true
    local rule = NS.Rules[a.ruleID]
    warning:SetText(rule.warning)
    for i, row in ipairs(rows) do
        local e = data[i]
        row.yes:Hide(); row.no:Hide(); row.text:Hide(); row.hover:Hide()
        row.entry = e
        if e then
            row.name = e.name
            local source = e.source == "leader" and "leader confirmed" or e.source == "automatic" and "automatic" or "unverified"
            row.text:SetText(e.name .. "\n" .. e.status .. " (" .. source .. ")")
            row.text:SetTextColor(unpack(colors[e.status]))
            row.text:Show()
            row.hover:Show()
            if e.canConfirm then row.yes:Show(); row.no:Show() end
        end
    end
    if engine.notice then footer:SetText(engine.notice)
    elseif a.started then footer:SetText("Action observed. Check everyone's progress. For another stage or attempt, regroup and use /zkir retry.")
    elseif engine:allReady() then footer:SetText("|cff59ff73You may proceed.|r " .. rule.nextAction)
    else footer:SetText("Wait for everyone. Leader confirmation token: " .. engine:fingerprint() ..
        ". Ready checks preparation, not guaranteed credit.") end
    local soloHidden = engine.count == 1 and options.solo == false and UI.forcedAttempt ~= attempt
    local becomingVisible = firstObservation or UI.soloSuppressedAttempt == attempt
    UI.soloSuppressedAttempt = soloHidden and attempt or nil
    if UI.hiddenKey == a.key or UI.hiddenAttempt == attempt or soloHidden then
        frame:Hide()
    else
        if becomingVisible and previewFrame then previewFrame:Hide() end
        frame:Show()
        if becomingVisible then frame:Raise() end
        if firstObservation and not presentationOnly and not engine.restoring and not a.started and
            options.sound ~= false and NS.PlayWarningSound then
            NS.PlayWarningSound()
        end
    end
end
function UI.show(engine)
    UI.hiddenKey, UI.hiddenAttempt = nil, nil
    UI.forcedAttempt = engine and engine.active and attemptID(engine.active)
    if previewFrame then previewFrame:Hide() end
    UI.update(engine, true)
    if frame and engine and engine.active then frame:Raise() end
end
function UI.applySettings()
    if NS.Settings and NS.Settings.values.solo == false and UI.lastSolo == true then
        UI.forcedAttempt = nil
    end
    if frame then frame:SetScale(scale()) end
    if previewFrame then previewFrame:SetScale(scale()) end
    UI.update(UI.engine, true)
end
function UI.resetPosition()
    if frame then position(frame) end
    if previewFrame then position(previewFrame) end
    if NS.Settings then NS.Settings.resetPosition() end
end
function UI.preview()
    if not previewFrame then
        previewFrame = createWindow("ZKIRPartyQuestingPreviewWindow")
        label(previewFrame, 14, -14, 400):SetText("|cffffd160ZKIR PARTY QUESTING - LOCAL PREVIEW|r")
        local close = button(previewFrame, "X", 22, function() previewFrame:Hide() end)
        close:SetPoint("TOPRIGHT", -9, -9)
        local sampleWarning = label(previewFrame, 14, -40, 442)
        sampleWarning:SetHeight(54)
        sampleWarning:SetText("Sample escort: wait for everyone before accepting. One acceptance starts the escort; finish prerequisite hand-ins first.")
        local samples = {
            {"Aria", "Ready", "automatic"}, {"Borin", "Not Ready", "automatic"},
            {"Cora", "Waiting", "unverified"}, {"Dain", "Unknown", "unverified"},
            {"Elya", "Ready", "leader confirmed"},
        }
        for i, sample in ipairs(samples) do
            local text = label(previewFrame, 14, -100 - (i - 1) * 33, 442)
            text:SetHeight(31)
            text:SetText(sample[1] .. " (sample)\n" .. sample[2] .. " (" .. sample[3] .. ")")
            text:SetTextColor(unpack(colors[sample[2]]))
        end
        local note = label(previewFrame, 14, -271, 442)
        note:SetHeight(52)
        note:SetText("Preview only: sample players and statuses. No party messages are sent and real readiness is unchanged.")
    end
    previewFrame:SetScale(scale())
    previewFrame:Show()
    previewFrame:Raise()
end
