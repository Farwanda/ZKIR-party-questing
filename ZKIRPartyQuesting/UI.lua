local _, NS = ...
local UI = {}
NS.UI = UI
local frame, warning, footer, rows
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
local function create()
    if frame then return end
    frame = CreateFrame("Frame", "ZKIRPartyQuestingWindow", UIParent, "BackdropTemplate")
    frame:SetSize(470, 338)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}})
    frame:SetBackdropColor(0.05, 0.05, 0.07, 0.97)
    label(frame, 14, -14, 400):SetText("|cffffd160ZKIR PARTY QUESTING|r")
    local close = button(frame, "X", 22, function()
        UI.hiddenKey = UI.engine.active.key
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
function UI.update(engine)
    UI.engine = engine
    if not engine.active then if frame then frame:Hide() end; return end
    create()
    local a, data = engine.active, engine:rows()
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
    if UI.hiddenKey ~= a.key then frame:Show() end
end
function UI.show(engine)
    UI.hiddenKey = nil
    UI.update(engine)
end
