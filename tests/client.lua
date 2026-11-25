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
    function methods:SetText(text) self.text = text end
    function methods:GetText() return self.text end
    function methods:Show() self.shown = true end
    function methods:Hide() self.shown = false end
    function methods:IsShown() return self.shown end
    function methods:Raise() self.raised = (rawget(self, "raised") or 0) + 1 end
    function methods:SetSize(width, height) self.width, self.height = width, height end
    function methods:SetWidth(width) self.width = width end
    function methods:SetHeight(height) self.height = height end
    function methods:GetWidth() return self.width end
    function methods:GetHeight() return self.height end
    function methods:SetScale(scale) self.scale = scale end
    function methods:GetScale() return self.scale or 1 end
    function methods:SetPoint(...) self.point = {...} end
    function methods:ClearAllPoints() self.point = nil end
    function methods:SetChecked(value) self.checked = value end
    function methods:GetChecked() return self.checked end
    function methods:Enable() self.enabled = true end
    function methods:Disable() self.enabled = false end
    function methods:IsEnabled() return self.enabled ~= false end
    local function object(parent)
        return setmetatable({scripts = {}, parent = parent, shown = true},
            {__index = function(_, k) return methods[k] or function() end end})
    end
    function methods:CreateFontString() local f = object(self); frames[#frames + 1] = f; return f end
    env.CreateFrame = function(kind, name, parent)
        local f = object(parent); f.kind, f.name = kind, name; frames[#frames + 1] = f
        if name then env[name] = f end
        return f
    end
    env.UIParent, env.SlashCmdList = object(), {}
    env.GetTime = function() return clock end
    env.GetServerTime = function() return 1000 + math.floor(clock) end
    env.UnitFullName = function(unit)
        if options.missingIdentity then return nil end
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
    env.UnitIsGroupLeader = function(unit) return unit == "player" end
    env.UnitIsConnected = function() return true end
    env.GetNumSubgroupMembers = function() return options.party and 1 or 0 end
    env.IsInRaid = function() return false end
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
    env.C_GossipInfo = {GetAvailableQuests = function() return {} end, SelectOption = function() end}
    env.hooksecurefunc = function(_, method, callback) hooks[method] = callback end
    env.AcceptQuest = function() error("addon must never accept a quest") end
    env.CompleteQuest = function() error("addon must never complete a quest") end
    env.GetQuestReward = function() error("addon must never claim a reward") end
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
    local function advance(n)
        for _ = 1, n * 2 do clock = clock + 0.5; driver.scripts.OnUpdate(driver, 0.5) end
    end
    event("PLAYER_LOGIN")
    return {env = env, ns = ns, event = event, advance = advance, frames = frames, messages = messages,
        hooks = hooks, state = state, sounds = sounds, options = options,
        setQuest = function(id) questID = id end}
end

return client
