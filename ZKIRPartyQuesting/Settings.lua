local _, NS = ...
local Settings = {values = {sound = true, solo = true, size = "Normal", ffaFriends = false, ffaCharacters = false}}
NS.Settings = Settings

local scales = {Small = 0.85, Normal = 1, Large = 1.15}
local callbacks, frame, heading, status, sound, solo = {}, nil
local sizeButtons = {}
local ffaFriends, ffaCharacters, lootStatus, charactersFrame, characterText, characterError
local lastPresentation

local label = NS.Widgets.label

local function button(text, width, onClick, parent)
    return NS.Widgets.button(parent or frame, text, width, onClick)
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
    if charactersFrame then
        charactersFrame:ClearAllPoints()
        charactersFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

local function showCharacters()
    if not charactersFrame then
        charactersFrame = NS.Widgets.window("ZKIRPartyQuestingCharactersWindow", 420, 330)
        charactersFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        label(charactersFrame, 14, -14, 350):SetText("|cffffd160AUTO FFA - CHARACTERS|r")
        local close = button("X", 22, function() charactersFrame:Hide() end, charactersFrame)
        close:SetPoint("TOPRIGHT", -9, -9)
        local help = label(charactersFrame, 14, -44, 392)
        help:SetHeight(40)
        help:SetText("One Name-Realm per line. A name without a realm uses your current realm. Saving the list does not enable the option.")
        local scroll = CreateFrame("ScrollFrame", "ZKIRPartyQuestingCharactersScroll", charactersFrame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 14, -93)
        scroll:SetSize(366, 150)
        characterText = CreateFrame("EditBox", "ZKIRPartyQuestingCharactersText", scroll)
        characterText:SetMultiLine(true)
        characterText:SetAutoFocus(false)
        characterText:SetMaxLetters(0)
        characterText:SetFontObject(ChatFontNormal)
        characterText:SetSize(358, 150)
        characterText:SetTextInsets(4, 4, 4, 4)
        scroll:SetScrollChild(characterText)
        characterText:SetScript("OnEscapePressed", function() charactersFrame:Hide() end)
        characterText:SetScript("OnTextChanged", function()
            scroll:UpdateScrollChildRect()
            if characterError then characterError:SetText("") end
        end)
        characterText:SetScript("OnCursorChanged", function(_, _, y, _, height)
            local offset, viewport = scroll:GetVerticalScroll(), scroll:GetHeight()
            if type(offset) ~= "number" or type(viewport) ~= "number" then return end
            if -y < offset then scroll:SetVerticalScroll(math.max(0, -y))
            elseif -y + height > offset + viewport then
                scroll:SetVerticalScroll(math.max(0, -y + height - viewport))
            end
        end)
        scroll:SetScript("OnMouseDown", function() characterText:SetFocus() end)
        charactersFrame:SetScript("OnHide", function() characterText:ClearFocus() end)
        if type(UISpecialFrames) == "table" then
            UISpecialFrames[#UISpecialFrames + 1] = "ZKIRPartyQuestingCharactersWindow"
        end
        characterError = label(charactersFrame, 14, -253, 392)
        characterError:SetHeight(32)
        characterError:SetTextColor(1, 0.4, 0.35)
        local save = button("Save", 92, function()
            local saved, message = NS.AutoLoot.setCharacters(characterText:GetText())
            if not saved then
                characterError:SetText(message)
                return
            end
            charactersFrame:Hide()
            changed()
        end, charactersFrame)
        save:SetPoint("BOTTOMRIGHT", -114, 14)
        local cancel = button("Cancel", 92, function() charactersFrame:Hide() end, charactersFrame)
        cancel:SetPoint("BOTTOMRIGHT", -14, 14)
    end
    characterText:SetText(NS.AutoLoot.charactersText())
    characterText:SetCursorPosition(0)
    characterError:SetText("")
    charactersFrame:SetScale(Settings.sizeScale())
    charactersFrame:Show()
    charactersFrame:Raise()
    characterText:SetFocus()
end

local function create()
    if frame then return end
    frame = NS.Widgets.window("ZKIRPartyQuestingSettingsWindow", 360, 458)
    Settings.resetPosition()
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
        NS.UI.preview()
    end)
    preview:SetPoint("TOPLEFT", 14, -199)
    local reset = button("Reset window position", 160, function()
        NS.UI.resetPosition()
    end)
    reset:SetPoint("TOPLEFT", 184, -199)
    label(frame, 14, -241, 332):SetText("|cffffd160Free for All outside dungeons|r")
    ffaFriends = checkbox("ZKIRPartyQuestingFFAFriendsCheckbox", "With Battle.net friends", -262, "ffaFriends")
    ffaCharacters = checkbox("ZKIRPartyQuestingFFACharactersCheckbox", "With these characters", -291, "ffaCharacters")
    local characters = button("Characters...", 104, showCharacters)
    characters:SetPoint("TOPRIGHT", -14, -294)
    local eligibility = label(frame, 14, -330, 332)
    eligibility:SetHeight(40)
    eligibility:SetText("When you lead: dungeons use Group Loot. Outside, FFA needs every other member to match either enabled option.")
    lootStatus = label(frame, 14, -378, 332)
    lootStatus:SetHeight(38)
    label(frame, 14, -430, 332):SetText("Party coordination always stays automatic.")
end

function Settings.init(db, options)
    callbacks = type(options) == "table" and options or {}
    if type(db.settings) ~= "table" then db.settings = {} end
    local values = db.settings
    if type(values.sound) ~= "boolean" then values.sound = true end
    if type(values.solo) ~= "boolean" then values.solo = true end
    if type(values.ffaFriends) ~= "boolean" then values.ffaFriends = false end
    if type(values.ffaCharacters) ~= "boolean" then values.ffaCharacters = false end
    if not scales[values.size] then values.size = "Normal" end
    Settings.values = values
    Settings.refresh()
end

function Settings.refresh(force)
    if not frame or not force and not frame:IsShown() then return end
    local version = type(callbacks.version) == "string" and callbacks.version or "unknown"
    local message = callbacks.status and callbacks.status() or "Waiting for a supported interaction."
    local lootMessage = NS.AutoLoot.status()
    local values = Settings.values
    local signature = table.concat({version, message, lootMessage, tostring(values.sound), tostring(values.solo),
        values.size, tostring(values.ffaFriends), tostring(values.ffaCharacters)}, "\031")
    if not force and signature == lastPresentation then return end
    lastPresentation = signature
    heading:SetText("|cffffd160ZKIR PARTY QUESTING|r\nv" .. version .. " - |cff59ff73Loaded|r")
    status:SetText(message)
    sound:SetChecked(values.sound)
    solo:SetChecked(values.solo)
    ffaFriends:SetChecked(values.ffaFriends)
    ffaCharacters:SetChecked(values.ffaCharacters)
    lootStatus:SetText(lootMessage)
    for size, control in pairs(sizeButtons) do
        control:SetText(size == Settings.values.size and ("|cffffd160" .. size .. "|r") or size)
    end
    frame:SetScale(Settings.sizeScale())
    if charactersFrame then charactersFrame:SetScale(Settings.sizeScale()) end
end

function Settings.show()
    create()
    frame:Show()
    Settings.refresh(true)
    frame:Raise()
end
