local _, NS = ...
local Settings = {values = {sound = true, solo = true, size = "Normal"}}
NS.Settings = Settings

local scales = {Small = 0.85, Normal = 1, Large = 1.15}
local callbacks, frame, heading, status, sound, solo = {}, nil
local sizeButtons = {}

local function label(parent, x, y, width)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", x, y)
    text:SetWidth(width)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    return text
end

local function button(text, width, onClick)
    local control = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    control:SetSize(width, 22)
    control:SetText(text)
    control:SetScript("OnClick", onClick)
    return control
end

local function changed()
    Settings.refresh()
    if type(callbacks.changed) == "function" then callbacks.changed() end
end

local function checkbox(name, text, y, key)
    local control = CreateFrame("CheckButton", name, frame, "UICheckButtonTemplate")
    control:SetSize(26, 26)
    control:SetPoint("TOPLEFT", 10, y)
    label(frame, 39, y - 7, 290):SetText(text)
    control:SetScript("OnClick", function(self)
        Settings.values[key] = self:GetChecked() == true
        changed()
    end)
    return control
end

function Settings.sizeScale()
    return scales[Settings.values.size] or 1
end

function Settings.resetPosition()
    if not frame then return end
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

local function create()
    if frame then return end
    frame = CreateFrame("Frame", "ZKIRPartyQuestingSettingsWindow", UIParent, "BackdropTemplate")
    frame:SetSize(360, 278)
    Settings.resetPosition()
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
    heading = label(frame, 14, -14, 307)
    heading:SetHeight(30)
    local close = button("X", 22, function() frame:Hide() end)
    close:SetPoint("TOPRIGHT", -9, -9)
    status = label(frame, 14, -50, 332)
    status:SetHeight(42)
    sound = checkbox("ZKIRPartyQuestingSoundCheckbox", "Warning sound", -95, "sound")
    solo = checkbox("ZKIRPartyQuestingSoloCheckbox", "Show solo warnings", -124, "solo")
    label(frame, 14, -164, 100):SetText("Window size")
    for index, size in ipairs({"Small", "Normal", "Large"}) do
        local choice = size
        sizeButtons[choice] = button(choice, 70, function()
            Settings.values.size = choice
            changed()
        end)
        sizeButtons[choice]:SetPoint("TOPLEFT", 112 + (index - 1) * 75, -158)
    end
    local preview = button("Preview warning", 160, function()
        if NS.UI then NS.UI.preview() end
    end)
    preview:SetPoint("TOPLEFT", 14, -199)
    local reset = button("Reset window position", 160, function()
        if NS.UI then NS.UI.resetPosition() else Settings.resetPosition() end
    end)
    reset:SetPoint("TOPLEFT", 184, -199)
    label(frame, 14, -238, 332):SetText("Party coordination always stays automatic.")
end

function Settings.init(db, options)
    callbacks = type(options) == "table" and options or {}
    if type(db.settings) ~= "table" then db.settings = {} end
    local values = db.settings
    if type(values.sound) ~= "boolean" then values.sound = true end
    if type(values.solo) ~= "boolean" then values.solo = true end
    if not scales[values.size] then values.size = "Normal" end
    Settings.values = values
    Settings.refresh()
end

function Settings.refresh()
    if not frame then return end
    local version = type(callbacks.version) == "string" and callbacks.version or "unknown"
    heading:SetText("|cffffd160ZKIR PARTY QUESTING|r\nv" .. version .. " - |cff59ff73Loaded|r")
    local message = "Waiting for a supported interaction."
    if type(callbacks.status) == "function" then
        local ok, value = pcall(callbacks.status)
        message = ok and type(value) == "string" and value or "Status unavailable."
    end
    status:SetText(message)
    sound:SetChecked(Settings.values.sound)
    solo:SetChecked(Settings.values.solo)
    for size, control in pairs(sizeButtons) do
        control:SetText(size == Settings.values.size and ("|cffffd160" .. size .. "|r") or size)
    end
    frame:SetScale(Settings.sizeScale())
end

function Settings.show()
    create()
    Settings.refresh()
    frame:Show()
    frame:Raise()
end
