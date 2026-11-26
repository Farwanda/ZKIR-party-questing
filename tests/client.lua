-- Runs the real TOC files with mocked public APIs and UI objects, not a game client.
local function client(options)
    local env = setmetatable({}, {__index = _G})
    local ns, frames, messages, hooks, sounds = {}, {}, {}, {}, {}
    local clock, questID = 0, 7046
    options = options or {}
    local state = {[7044] = {rewarded = true, active = false}, [7046] = {rewarded = false, active = false},
        [2098] = {rewarded = true}, [2078] = {rewarded = false, active = true, complete = false},
        [4201] = {rewarded = false, active = true, complete = true}}
    local methods = {}
    function methods:SetScript(name, fn) self.scripts[name] = fn end
    function methods:GetScript(name) return self.scripts[name] end
    function methods:HookScript(name, fn)
        self.scriptHooks[name] = self.scriptHooks[name] or {}
        table.insert(self.scriptHooks[name], fn)
    end
    local function runScript(self, name, ...)
        if self.scripts[name] then self.scripts[name](self, ...) end
        for _, callback in ipairs(self.scriptHooks[name] or {}) do callback(self, ...) end
    end
    function methods:SetText(text) self.text = text; self.textWrites = (self.textWrites or 0) + 1 end
    function methods:GetText() return self.text end
    function methods:Show()
        if self.shown then return end
        self.shown = true; runScript(self, "OnShow")
    end
    function methods:Hide()
        if not self.shown then return end
        self.shown = false; runScript(self, "OnHide")
    end
    function methods:IsShown() return self.shown end
    function methods:IsVisible() return self.shown and (not self.parent or self.parent:IsVisible()) end
    function methods:Raise() self.raised = (rawget(self, "raised") or 0) + 1 end
    function methods:SetSize(width, height) self.width, self.height = width, height end
    function methods:SetWidth(width) self.width = width end
    function methods:SetHeight(height) self.height = height end
    function methods:GetWidth() return self.width end
    function methods:GetHeight() return self.height end
    function methods:SetScale(scale) self.scale = scale end
    function methods:GetScale() return self.scale or 1 end
    function methods:GetEffectiveScale() return self:GetScale() * (self.parent and self.parent:GetEffectiveScale() or 1) end
    function methods:SetPoint(...) self.point = {...} end
    function methods:ClearAllPoints() self.point = nil end
    function methods:GetPoint() if self.point then return unpack(self.point) end end
    function methods:GetNumPoints() return self.point and 1 or 0 end
    function methods:GetParent() return self.parent end
    local function offset(point, width, height)
        local x = point:find("LEFT", 1, true) and 0 or point:find("RIGHT", 1, true) and width or width / 2
        local y = point:find("BOTTOM", 1, true) and 0 or point:find("TOP", 1, true) and height or height / 2
        return x, y
    end
    local function bounds(self)
        local width, height = self.width or 0, self.height or 0
        if self == env.UIParent then return 0, 0, width, height end
        local p = self.point or {"CENTER", self.parent or env.UIParent, "CENTER", 0, 0}
        local target, point, x, y = p[2], p[3], p[4], p[5]
        if type(target) == "number" then target, point, x, y = self.parent, p[1], p[2], p[3] end
        if type(target) == "string" then target = env[target] end
        target = target or self.parent or env.UIParent
        point = type(point) == "string" and point or p[1]
        local left, bottom, targetWidth, targetHeight = bounds(target)
        local targetX, targetY = offset(point, targetWidth, targetHeight)
        local ownX, ownY = offset(p[1], width, height)
        return left + targetX + (x or 0) - ownX, bottom + targetY + (y or 0) - ownY, width, height
    end
    function methods:GetLeft() return (bounds(self)) end
    function methods:GetBottom() local _, bottom = bounds(self); return bottom end
    function methods:GetRight() local left, _, width = bounds(self); return left + width end
    function methods:GetTop() local _, bottom, _, height = bounds(self); return bottom + height end
    function methods:GetCenter() local left, bottom, width, height = bounds(self); return left + width / 2, bottom + height / 2 end
    function methods:SetFont(path, size, flags) self.font = {path, size, flags}; return true end
    function methods:GetFont() return unpack(self.font or {"mock-font", 12, ""}) end
    function methods:GetStringWidth()
        local longest = 0
        for line in tostring(self.text or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gmatch("[^\n]+") do
            longest = math.max(longest, #line * 6)
        end
        return longest
    end
    function methods:GetStringHeight()
        local lines, width = 0, self.width or math.huge
        for line in (tostring(self.text or "") .. "\n"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gmatch("(.-)\n") do
            lines = lines + math.max(1, math.ceil(#line * 6 / math.max(width, 1)))
        end
        return lines * ((self.font and self.font[2]) or 12)
    end
    function methods:SetWordWrap(value) self.wordWrap = value end
    function methods:SetMaxLines(value) self.maxLines = value end
    function methods:SetTextColor(...) self.textColor = {...} end
    function methods:SetChecked(value) self.checked = value end
    function methods:GetChecked() return self.checked end
    function methods:Enable() self.enabled = true end
    function methods:Disable() self.enabled = false end
    function methods:IsEnabled() return self.enabled ~= false end
    function methods:SetVerticalScroll(value) self.scroll = value end
    function methods:GetVerticalScroll() return self.scroll or 0 end
    function methods:SetScrollChild(child) self.scrollChild = child end
    function methods:SetOwner(owner) self.owner = owner end
    function methods:AddLine(value) self.text = (self.text or "") .. "\n" .. value end
    function methods:RegisterEvent(name) self.events[name] = true end
    function methods:SetClampedToScreen(value) self.clamped = value end
    function methods:SetMovable(value) self.movable = value end
    function methods:StartMoving() self.moving = true end
    function methods:StopMovingOrSizing() self.moving = false end
    -- Only decoration/input setup is inert. Missing geometry and lifecycle methods fail.
    for _, name in ipairs({"EnableMouse", "RegisterForDrag", "SetBackdrop", "SetBackdropColor",
        "SetFrameStrata", "SetJustifyH", "SetJustifyV", "SetAutoFocus", "SetCursorPosition",
        "SetFontObject", "SetMaxLetters", "SetMultiLine", "SetTextInsets", "SetFocus", "ClearFocus",
        "UpdateScrollChildRect"}) do
        methods[name] = function() end
    end
    local function object(parent)
        return setmetatable({scripts = {}, scriptHooks = {}, events = {}, parent = parent, shown = true},
            {__index = methods})
    end
    function methods:CreateFontString() local f = object(self); frames[#frames + 1] = f; return f end
    env.CreateFrame = function(kind, name, parent)
        local f = object(parent); f.kind, f.name = kind, name; frames[#frames + 1] = f
        if name then env[name] = f end
        return f
    end
    env.UIParent, env.SlashCmdList = object(), {}
    env.UIParent:SetSize(options.screenWidth or 1920, options.screenHeight or 1080)
    env.GetScreenWidth = function() return env.UIParent:GetWidth() end
    env.GetScreenHeight = function() return env.UIParent:GetHeight() end
    for _, name in ipairs({"QuestFrame", "GossipFrame"}) do
        local f = env.CreateFrame("Frame", name, env.UIParent)
        f:SetSize(384, 512); f:SetPoint("TOPLEFT", env.UIParent, "TOPLEFT", 20, -80); f:Hide()
    end
    env.GameTooltip = env.CreateFrame("GameTooltip", "GameTooltip", env.UIParent)
    env.GameTooltip:Hide()
    env.GetTime = function() return clock end
    env.GetServerTime = function() return 1000 + math.floor(clock) end
    env.UnitFullName = function(unit)
        if options.missingIdentity then return nil end
        local member = options.members and options.members[unit]
        if member then return member.name, member.realm or "Realm" end
        return unit == "player" and "Alice" or "Bob", "Realm"
    end
    env.ZKIRPartyQuestingDB = options.db
    local version
    env.C_AddOns = {GetAddOnMetadata = function(_, key) if key == "Version" then return version end end}
    env.GetAddOnMetadata = env.C_AddOns.GetAddOnMetadata
    env.SOUNDKIT = {RAID_WARNING = 8959}
    if not options.missingSound then
        env.PlaySound = function(...)
            sounds[#sounds + 1] = {...}
            if options.throwSound then error("Sound unavailable") end
            return true
        end
    end
    env.GetNormalizedRealmName = function() return "Realm" end
    env.UnitIsGroupLeader = function(unit) return unit == (options.leader or "player") end
    env.UnitIsConnected = function(unit)
        local member = options.members and options.members[unit]
        return not member or member.connected ~= false
    end
    env.GetNumSubgroupMembers = function() return type(options.party) == "number" and options.party or options.party and 1 or 0 end
    env.IsInRaid = function() return false end
    env.IsInInstance = function() return options.inInstance == true, options.instanceType or "none" end
    env.UnitLevel = function() return 60 end
    env.UnitFactionGroup = function() return "Alliance" end
    env.UnitClass = function() return "Warrior", "WARRIOR", 1 end
    env.UnitRace = function() return "Human", "Human", 1 end
    env.UnitGUID = function() return options.guid or "Creature-0-1-1-1-13716-0001" end
    env.GetQuestID = function() return questID end
    env.InChatMessagingLockdown = function() return options.locked or false end
    env.issecretvalue = function(v) return type(v) == "table" and v.secret == true end
    env.C_QuestLog = {
        GetNumQuestLogEntries = function() return 40, 2 end, -- headers must not fill the log
        GetMaxNumQuestsCanAccept = function() return 25 end,
    }
    for method, key in pairs({IsQuestFlaggedCompleted = "rewarded", IsOnQuest = "active", IsFailed = "failed", IsComplete = "complete"}) do
        env.C_QuestLog[method] = function(id)
            local q = state[id] or {}
            if options.secretHistory and key == "rewarded" then return {secret = true} end
            if q[key] == nil then return false end
            return q[key]
        end
    end
    env.C_ChatInfo = {
        RegisterAddonMessagePrefix = function() return options.registration or 0 end,
        SendAddonMessage = function(_, data, channel)
            messages[#messages + 1] = {data = data, channel = channel}
            if options.nilSend then return nil end
            return options.sendResult or 0
        end,
        SendChatMessage = function(data, channel) messages[#messages + 1] = {chat = data, channel = channel} end,
    }
    env.C_GossipInfo = {GetAvailableQuests = function() return {} end}
    for _, method in ipairs({"SelectOption", "SelectOptionByIndex"}) do
        env.C_GossipInfo[method] = function(...)
            if options.selectGossip then return options.selectGossip(method, ...) end
        end
    end
    env.hooksecurefunc = function(target, method, callback)
        hooks[method] = callback
        local original = target[method]
        assert(type(original) == "function", "posthook requires an existing game function")
        target[method] = function(...) original(...); return callback(...) end
    end
    env.AcceptQuest = function() error("addon must never accept a quest") end
    env.CompleteQuest = function() error("addon must never complete a quest") end
    env.GetQuestReward = function() error("addon must never claim a reward") end
    if options.install then options.install(env, ns) end
    for line in io.lines("ZKIRPartyQuesting/ZKIRPartyQuesting.toc") do
        version = line:match("^## Version: (.+)$") or version
        if line:match("%.lua$") then
            local chunk = assert(loadfile("ZKIRPartyQuesting/" .. line)); setfenv(chunk, env); chunk("ZKIRPartyQuesting", ns)
        end
    end
    local driver
    for _, f in ipairs(frames) do if f.scripts.OnEvent then driver = f; break end end
    assert(driver, "addon event driver missing")
    local function event(name, ...) driver.scripts.OnEvent(driver, name, ...) end
    local function frame(delta)
        clock = clock + delta
        driver.scripts.OnUpdate(driver, delta)
    end
    local function advance(n)
        for _ = 1, n * 2 do frame(0.5) end
    end
    event("PLAYER_LOGIN")
    return {env = env, ns = ns, event = event, advance = advance, frame = frame, frames = frames, messages = messages,
        hooks = hooks, state = state, sounds = sounds, options = options,
        setQuest = function(id) questID = id end}
end

return client
