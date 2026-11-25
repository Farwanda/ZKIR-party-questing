local _, NS = ...
local UI = {}
NS.UI = UI
local panel, previewPanel
local observedAttempts = {}
local colors = {Ready = {0.35, 1, 0.45}, ["Not Ready"] = {1, 0.4, 0.35},
    Waiting = {1, 0.85, 0.35}, Unknown = {0.75, 0.75, 0.75}}
local WIDTH, INSET = 340, 14
local function defaultPosition(window)
    window:ClearAllPoints()
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
end
local function scale()
    return NS.Settings and NS.Settings.sizeScale() or 1
end
local function attemptID(active)
    -- Concurrent detections converge on a different key but share these fields.
    -- A deliberate retry has the previous key as its parent and is a new warning.
    return table.concat({active.parent or "0", active.ruleID or "", active.context or ""}, "\031")
end
local render

-- Font strings size themselves to their actual text; the fallback also supports
-- restricted or unavailable font measurements without hiding instructions.
local function place(text, value, x, y, width, lineHeight)
    text:ClearAllPoints()
    text:SetPoint("TOPLEFT", x, -y)
    text:SetWidth(width)
    text:SetHeight(0)
    text:SetText(value)
    local height = text:GetStringHeight()
    if type(height) ~= "number" or height <= 0 then
        local lines = 0
        for line in (value .. "\n"):gmatch("(.-)\n") do
            lines = lines + math.max(1, math.ceil(#line / math.max(1, math.floor(width / 7))))
        end
        height = math.max(1, lines) * (lineHeight or 14)
    end
    text:SetHeight(height)
    text:Show()
    return height
end

local function position(p)
    local anchor = not p.preview and UI.anchor
    local side
    if anchor then
        local right, screen = anchor:GetRight(), UIParent:GetWidth()
        local anchorScale, parentScale = anchor:GetEffectiveScale(), UIParent:GetEffectiveScale()
        local panelScale = p.frame:GetEffectiveScale()
        side = "right"
        if type(right) == "number" and type(screen) == "number" and type(anchorScale) == "number" and
            type(parentScale) == "number" and type(panelScale) == "number" and
            right * anchorScale + (WIDTH + 6) * panelScale > screen * parentScale then side = "left" end
    end
    if p.anchor == anchor and p.side == side then return end
    p.anchor, p.side = anchor, side
    p.frame:ClearAllPoints()
    if anchor then
        if side == "left" then p.frame:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -6, -10)
        else p.frame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 6, -10) end
    elseif p.fallback then p.frame:SetPoint(unpack(p.fallback))
    else defaultPosition(p.frame) end
end

local function confirm(p, row, state)
    local engine = UI.engine
    -- A menu can remain under the cursor while the party or evidence changes.
    -- Re-read permission rather than trusting the previously rendered row.
    if not row.entry or p.selected ~= row.entry.name or not engine or not engine.active or engine.active.started or
        p.attempt ~= attemptID(engine.active) or p.fingerprint ~= engine:fingerprint() then return end
    for _, current in ipairs(engine:rows()) do
        if current.name == row.entry.name and current.canConfirm then
            p.selected = nil
            engine:confirm(current.name, state)
            UI.update(engine, true)
            return
        end
    end
end

local function create(name, preview)
    local widgets = NS.Widgets
    local p = {frame = widgets.window(name, WIDTH, 120), rows = {}, preview = preview}
    local window = p.frame
    defaultPosition(window)
    window:SetScale(scale())
    window:SetScript("OnDragStart", function(self) if not p.anchor then self:StartMoving() end end)
    window:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if not p.anchor then p.fallback = {self:GetPoint()} end
    end)
    p.title = widgets.label(window, INSET, -14, 274)
    p.title:SetTextColor(1, 0.82, 0.38)
    p.instruction = widgets.label(window, INSET, -38, 312, "GameFontNormalLarge")
    p.consequence = widgets.label(window, INSET, -64, 312)
    p.footer = widgets.label(window, INSET, -100, 312)
    p.details = widgets.label(window, INSET, -120, 312)
    local close = widgets.button(window, "X", 22, function()
        if not preview then
            local active = UI.engine and UI.engine.active
            UI.hiddenKey = active and active.key
            UI.hiddenAttempt = active and attemptID(active)
        end
        window:Hide()
    end)
    close:SetPoint("TOPRIGHT", -9, -9)
    p.detailsButton = widgets.button(window, "Details", 65, function()
        p.expanded = not p.expanded
        p.signature = nil
        render(p, p.view)
    end, 20)
    for i = 1, 5 do
        local row = {name = widgets.label(window, INSET, 0, 146),
            status = widgets.label(window, 166, 0, 160), detail = widgets.label(window, INSET, 0, 312)}
        row.hover = CreateFrame("Frame", nil, window)
        row.hover:EnableMouse(true)
        row.hover:SetScript("OnEnter", function(self)
            if not row.entry or not GameTooltip then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(row.entry.name)
            GameTooltip:AddLine(NS.Messages.reason(row.entry.reason, p.view.rule, NS.QuestTitle), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        row.hover:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
        if not preview then
            row.check = widgets.button(window, "Check", 58, function()
                if not row.entry or not row.entry.canConfirm then return end
                p.selected = p.selected ~= row.entry.name and row.entry.name or nil
                p.signature = nil
                UI.update(UI.engine, true)
            end, 20)
            row.yes = widgets.button(window, "Ready", 64, function() confirm(p, row, "R") end, 20)
            row.no = widgets.button(window, "Not ready", 82, function() confirm(p, row, "N") end, 20)
        end
        p.rows[i] = row
    end
    return p
end

local function shortNames(data)
    local counts, names = {}, {}
    for _, row in ipairs(data) do
        local name = row.name:match("^[^-]+") or row.name
        counts[name] = (counts[name] or 0) + 1
    end
    for _, row in ipairs(data) do
        local name = row.name:match("^[^-]+") or row.name
        names[row.name] = counts[name] == 1 and name or row.name
    end
    return names
end

render = function(p, view)
    p.view = view
    local rule, data, names = view.rule, view.rows, shortNames(view.rows)
    local instruction, consequence, footer = NS.Messages.instruction(rule), NS.Messages.consequence(rule), ""
    if view.started then
        instruction = rule.kind == "gossip" and "CHOICE MADE." or "ACTION TAKEN."
        consequence, footer = view.notice or "", "Check your progress."
    elseif view.notice then instruction, consequence = "WAIT.", view.notice
    elseif view.ready then instruction, consequence = "ALL READY", NS.Messages.nextAction(rule)
    else
        local ready, waiting = 0, {}
        for _, row in ipairs(data) do
            if row.status == "Ready" then ready = ready + 1 else waiting[#waiting + 1] = names[row.name] end
        end
        footer = #waiting == 1 and ("Waiting for " .. waiting[1] .. ".") or
            (#waiting == 0 and "Checking..." or ("Waiting — " .. ready .. "/" .. #data .. " ready."))
    end
    if p.preview then footer = "Local preview. Sample players." end
    local details = NS.Messages.details(rule)
    local parts = {view.title, instruction, consequence, footer, details, tostring(p.expanded), p.selected or "",
        view.attempt or "", view.fingerprint or ""}
    for _, entry in ipairs(data) do
        parts[#parts + 1] = table.concat({entry.name, entry.status, entry.source or "",
            NS.Messages.reason(entry.reason, rule, NS.QuestTitle),
            tostring(entry.canConfirm)}, "\031")
    end
    local signature = table.concat(parts, "\030")
    position(p)
    if signature == p.signature then return end
    p.signature, p.attempt, p.fingerprint = signature, view.attempt, view.fingerprint
    local y = 14 + place(p.title, view.title, INSET, 14, 274) + 12
    y = y + place(p.instruction, instruction, INSET, y, 312, 18) + 6
    p.instruction:SetTextColor(unpack(view.ready and not view.notice and not view.started and colors.Ready or {1, 0.82, 0.38}))
    p.consequence:Hide()
    if consequence ~= "" then y = y + place(p.consequence, consequence, INSET, y, 312) + 10 end
    for i, row in ipairs(p.rows) do
        row.name:Hide(); row.status:Hide(); row.detail:Hide(); row.hover:Hide()
        if row.check then row.check:Hide(); row.yes:Hide(); row.no:Hide() end
        local entry = not view.started and data[i] or nil
        row.entry = entry
        if entry then
            local top = y
            local status = entry.status .. (entry.source == "leader" and " · Leader" or "")
            local height = math.max(place(row.name, names[entry.name], INSET, y, 146),
                place(row.status, status, 166, y, 160))
            row.status:SetTextColor(unpack(colors[entry.status] or colors.Unknown))
            row.hover:ClearAllPoints(); row.hover:SetPoint("TOPLEFT", INSET, -y)
            row.hover:SetSize(312, height); row.hover:Show()
            y = y + height + 3
            local actionable = entry.status == "Not Ready" or entry.status == "Unknown"
            if actionable or entry.canConfirm then
                local reason = actionable and NS.Messages.reason(entry.reason, rule, NS.QuestTitle) or ""
                local detailHeight = place(row.detail, reason, INSET, y, entry.canConfirm and 244 or 312)
                row.detail:SetTextColor(0.8, 0.8, 0.8)
                if entry.canConfirm and row.check then
                    row.check:ClearAllPoints(); row.check:SetPoint("TOPRIGHT", -INSET, -y + 2); row.check:Show()
                    detailHeight = math.max(detailHeight, 20)
                end
                y = y + detailHeight + 3
            end
            if entry.canConfirm and row.check and p.selected == entry.name then
                row.yes:ClearAllPoints(); row.yes:SetPoint("TOPLEFT", INSET, -y); row.yes:Show()
                row.no:ClearAllPoints(); row.no:SetPoint("TOPLEFT", INSET + 68, -y); row.no:Show()
                y = y + 24
            end
            y = math.max(y, top + 20) + 5
        end
    end
    y = y + 4
    p.footer:Hide()
    if footer ~= "" then y = y + place(p.footer, footer, INSET, y, 312) + 8 end
    p.detailsButton:ClearAllPoints(); p.detailsButton:SetPoint("TOPLEFT", INSET, -y)
    p.detailsButton:SetText(p.expanded and "Less" or "Details")
    p.details:Hide()
    y = y + 24
    if p.expanded then y = y + place(p.details, details, INSET, y, 312) + 6 end
    p.frame:SetHeight(y + 10)
end
function UI.update(engine, presentationOnly)
    UI.engine = engine
    local options = NS.Settings and NS.Settings.values or {}
    UI.lastSolo = options.solo ~= false
    if not engine or not engine.active then if panel then panel.frame:Hide() end; return end
    if not panel then panel = create("ZKIRPartyQuestingWindow") end
    local frame = panel.frame
    local a, data = engine.active, engine:rows()
    local attempt = attemptID(a)
    local firstObservation = not observedAttempts[attempt]
    observedAttempts[attempt] = true
    local rule, fingerprint = NS.Rules[a.ruleID], engine:fingerprint()
    if panel.attempt ~= attempt or panel.fingerprint ~= fingerprint then panel.selected = nil end
    render(panel, {rule = rule, rows = data, title = rule.title, ready = engine:allReady(),
        notice = engine.notice, started = a.started, attempt = attempt, fingerprint = fingerprint})
    local soloHidden = engine.count == 1 and options.solo == false and UI.forcedAttempt ~= attempt
    local becomingVisible = firstObservation or UI.soloSuppressedAttempt == attempt
    UI.soloSuppressedAttempt = soloHidden and attempt or nil
    if UI.hiddenKey == a.key or UI.hiddenAttempt == attempt or soloHidden then
        frame:Hide()
    else
        if becomingVisible and previewPanel then previewPanel.frame:Hide() end
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
    if previewPanel then previewPanel.frame:Hide() end
    UI.update(engine, true)
    if panel and engine and engine.active then panel.frame:Raise() end
end
function UI.applySettings()
    if NS.Settings and NS.Settings.values.solo == false and UI.lastSolo == true then
        UI.forcedAttempt = nil
    end
    if panel then panel.frame:SetScale(scale()); panel.signature = nil end
    if previewPanel then
        previewPanel.frame:SetScale(scale()); previewPanel.signature = nil
        render(previewPanel, previewPanel.view)
    end
    UI.update(UI.engine, true)
end
function UI.setAnchor(anchor)
    UI.anchor = anchor
    if panel then position(panel) end
end
function UI.resetPosition()
    for _, p in pairs({panel, previewPanel}) do
        p.fallback, p.anchor, p.side = nil, nil, nil
        defaultPosition(p.frame)
        position(p)
    end
    if NS.Settings then NS.Settings.resetPosition() end
end
function UI.preview()
    if not previewPanel then previewPanel = create("ZKIRPartyQuestingPreviewWindow", true) end
    render(previewPanel, {rule = NS.Rules.a7046, title = "Local preview — sample escort", ready = false, rows = {
        {name = "Aria", status = "Ready", source = "automatic", reason = "PREPARED"},
        {name = "Borin", status = "Not Ready", source = "automatic", reason = "HAND_IN_7044"},
        {name = "Cora", status = "Waiting", reason = "WAITING"},
        {name = "Dain", status = "Unknown", reason = "NO_RESPONSE"},
        {name = "Elya", status = "Ready", source = "leader", reason = "LEADER_CONFIRMED"},
    }})
    previewPanel.frame:SetScale(scale())
    previewPanel.frame:Show()
    previewPanel.frame:Raise()
end
