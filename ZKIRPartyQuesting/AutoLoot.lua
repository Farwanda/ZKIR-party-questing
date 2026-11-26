-- Leader-local loot policy. No chat, peer messages, or automatic quest actions.
local _, NS = ...
local Loot = {}
NS.AutoLoot = Loot

local saved, owner, pending, observedMethod, partyGUID
local lastHome, stableKey, stableSince, failedKey, lastOptions
local manualEvent, authorityLost, awaitingLeave = false, false, false
local lastPlace, dungeonFailed
local restrictionEvents = {}
local message = "Auto FFA is off."
local restrictions = {"Combat", "Encounter", "ChallengeMode", "PvPMatch", "Map"}

local public, read, field = NS.API.public, NS.API.read, NS.API.field
local function api(name) return C_PartyInfo and C_PartyInfo[name] end
local function enum(name) return field(Enum and Enum.LootMethod, name) end
local function options() return NS.Settings.values end
local function enabled() return options().ffaFriends == true or options().ffaCharacters == true end
local function now()
    local t = read(GetTime)
    if type(t) == "number" and t == t and t >= 0 and t < 10000000000 then return t end
    return nil
end
local function text(v) return public(v) and type(v) == "string" and v ~= "" end
local function normalName(name, realm)
    if not text(name) or not text(realm) then return nil end
    name, realm = name:match("^%s*(.-)%s*$"), realm:gsub("%s", "")
    if name == "" or realm == "" or name:find("[%s%p]") or realm:find("[|,;:%c/\\]") then return nil end
    return (name .. "-" .. realm):lower()
end
local function fullName(unit)
    local name, realm = read(UnitFullName, unit)
    if realm == nil or realm == "" then realm = read(GetNormalizedRealmName) end
    local key = normalName(name, realm)
    if key then return name .. "-" .. realm:gsub("%s", ""), key end
    return nil
end
local function tell(value)
    if message ~= value and DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
        pcall(DEFAULT_CHAT_FRAME.AddMessage, DEFAULT_CHAT_FRAME, "ZKIR Auto FFA: " .. value)
    end
    message = value
end
local function pause(reason, warning)
    owner, pending, stableKey = nil, nil, nil
    saved.hold = reason
    if warning then tell(warning) end
end
local function resetParty()
    owner, pending, stableKey, failedKey, observedMethod, partyGUID = nil, nil, nil, nil, nil, nil
    manualEvent, authorityLost, awaitingLeave = false, false, false
    lastPlace, dungeonFailed = nil, nil
    saved.hold = nil
end

local function place()
    local inside, kind = read(IsInInstance)
    if inside == true and kind == "party" then return "dungeon" end
    if inside == false and kind == "none" then return "outdoor" end
    return nil
end

local function roster()
    local count = read(GetNumSubgroupMembers)
    if type(count) ~= "number" or count < 1 or count > 4 or count % 1 ~= 0 then return nil end
    local members, identities, seen = {}, {}, {}
    for i = 0, count do
        local unit = i == 0 and "player" or "party" .. i
        local guid = read(UnitGUID, unit)
        local name, key = fullName(unit)
        if not text(guid) or not guid:match("^Player%-") or seen[guid] or not key then return nil end
        seen[guid] = true
        local member = {unit = unit, guid = guid, name = name, key = key,
            connected = read(UnitIsConnected, unit), combat = read(UnitAffectingCombat, unit)}
        members[#members + 1] = member
        identities[#identities + 1] = guid .. ":" .. key
    end
    table.sort(identities)
    return members, table.concat(identities, "|")
end
local function context()
    local home = read(IsInGroup, LE_PARTY_CATEGORY_HOME or 1)
    if home == false then return nil, "Waiting for a party.", false, true end
    local raid, instance = read(IsInRaid), read(IsInGroup, LE_PARTY_CATEGORY_INSTANCE or 2)
    if home ~= true or raid ~= false or instance ~= false then
        return nil, "Waiting for an ordinary party of 2-5.", home, raid == true or instance == true
    end
    local leader = read(UnitIsGroupLeader, "player")
    if leader ~= true then return nil, "Only the party leader can set loot.", home, leader == false end
    local members, identity = roster()
    return {members = members, identity = identity}, nil, home
end
local function idle(members)
    if read(InCombatLockdown) ~= false or read(UnitAffectingCombat, "player") ~= false then
        return false, "Waiting until combat ends."
    end
    if read(GetNumLootItems) ~= 0 or LootFrame and read(LootFrame.IsShown, LootFrame) ~= false then
        return false, "Waiting until looting ends."
    end
    if type(C_RestrictedActions and C_RestrictedActions.GetAddOnRestrictionState) == "function" then
        for _, name in ipairs(restrictions) do
            local kind = field(Enum and Enum.AddOnRestrictionType, name)
            if type(kind) ~= "number" or read(C_RestrictedActions.GetAddOnRestrictionState, kind) ~= 0 or
                restrictionEvents[name] == 1 or restrictionEvents[name] == 2 then
                return false, "Waiting for game restrictions to clear."
            end
        end
    end
    for _, member in ipairs(members or {}) do
        if member.combat ~= false then return false, "Waiting until the party is out of combat." end
    end
    return true
end
local function trusted(members)
    local evidence, ready = {}, true
    local bn = C_BattleNet or {}
    local connected = read(BNConnected) == true
    if type(bn.IsBattleNetFriendsListSupported) == "function" and read(bn.IsBattleNetFriendsListSupported) ~= true then connected = false end
    if type(bn.IsBattleNetFriendsListEnabled) == "function" and read(bn.IsBattleNetFriendsListEnabled) ~= true then connected = false end
    for _, member in ipairs(members) do
        local match = member.unit == "player"
        if not match and options().ffaCharacters == true and options().ffaNames[member.key] == true then match = true end
        if not match and options().ffaFriends == true and connected then
            local account = read(bn.GetAccountInfoByGUID, member.guid)
            match = field(account, "isFriend") == true
        end
        match = match and member.connected == true
        if not match then ready = false end
        evidence[#evidence + 1] = member.guid .. (match and ":yes" or ":no")
    end
    table.sort(evidence)
    return ready, table.concat(evidence, "|")
end
local function capture(method, masterParty, members)
    for _, name in ipairs({"Group", "Roundrobin", "Needbeforegreed", "Masterlooter"}) do
        if type(method) == "number" and method == enum(name) then
            local previous = {method = method}
            if name == "Masterlooter" then
                if type(masterParty) ~= "number" or masterParty < 0 or masterParty % 1 ~= 0 then return nil end
                local member = members[masterParty + 1]
                if not member then return nil end
                previous.master = member.guid
            end
            return previous
        end
    end
    return nil
end
local function masterName(previous, members)
    if not previous.master then return nil, true end
    for _, member in ipairs(members or {}) do
        if member.guid == previous.master then return member.name, true end
    end
    return nil, false
end
local function dungeonResult(confirmed, hold)
    owner, pending, stableKey = nil, nil, nil
    dungeonFailed = not confirmed
    saved.hold = hold or (not confirmed and "interrupted" or nil)
    if confirmed then message = "Dungeon: Group Loot."
    else tell("Dungeon Group Loot was not confirmed. Check loot manually; toggle an Auto FFA option to retry.") end
end
local function request(kind, target, from, previous, key, members, t)
    local master, valid = masterName(previous, members)
    if kind == "restore" and not valid then
        pause("interrupted", "Previous master looter is unavailable. Choose loot manually.")
        return
    end
    pending = {kind = kind, target = target, from = from, previous = previous, key = key, deadline = t + 5}
    saved.hold = "pending"
    -- Authority and state were checked in this tick. Event callbacks only observe.
    local success = read(api("SetLootMethod"), target, kind == "restore" and master or nil)
    if success ~= true then
        if kind == "dungeon" then dungeonResult(false, previous.hold); return end
        failedKey = key
        pause(kind == "restore" and "interrupted" or "failed", "Loot change was not accepted. Check loot manually; toggle an Auto FFA option to retry.")
        return
    end
    message = kind == "dungeon" and "Setting dungeon Group Loot; waiting for confirmation." or
        (kind == "apply" and "Setting FFA; waiting for confirmation." or "Restoring the previous loot method.")
end
local function pollPending(method, masterParty, members, t)
    if not pending then return false end
    local confirmed = method == pending.target
    if confirmed and pending.kind == "restore" and pending.previous.master then
        local member = members and type(masterParty) == "number" and members[masterParty + 1]
        confirmed = member and member.guid == pending.previous.master
    end
    if confirmed then
        if pending.kind == "apply" then
            owner = pending.previous
            saved.hold = "owned"
            message = "FFA confirmed; checking the current party."
        elseif pending.kind == "dungeon" then
            dungeonResult(true, pending.previous.hold)
        else
            owner, saved.hold, stableKey = nil, nil, nil
            message = "Previous loot method restored."
        end
        pending = nil
    elseif t >= pending.deadline then
        if pending.kind == "dungeon" then dungeonResult(false, pending.previous.hold); return true end
        failedKey = pending.key
        local restoration = pending.kind == "restore"
        pause(restoration and "interrupted" or "failed", restoration and
            "Restoration was not confirmed. Check party loot manually." or
            "FFA was not confirmed. Check loot; toggle an Auto FFA option to retry.")
    end
    return true
end

local function dungeon(state, method, t)
    stableKey = nil
    local count, group = read(GetNumSubgroupMembers), enum("Group")
    if type(count) ~= "number" or count < 1 or count > 4 or count % 1 ~= 0 then
        message = "Dungeon: waiting for a party of 2-5."; return
    end
    if type(method) ~= "number" or type(group) ~= "number" then
        message = "Dungeon: waiting for loot information."; return
    end
    if method == group then
        owner, dungeonFailed = nil, nil
        if saved.hold == "owned" then saved.hold = nil end
        message = "Dungeon: Group Loot."; return
    end
    if dungeonFailed then
        message = "Dungeon Group Loot failed. Check loot manually; toggle an Auto FFA option to retry."; return
    end
    local safe, why = idle()
    if not safe then message = "Dungeon Group Loot pending. " .. why; return end
    if type(api("SetLootMethod")) ~= "function" or read(api("IsLootMethodAvailable"), group) ~= true then
        message = "Dungeon Group Loot is unavailable. Check loot manually."; return
    end
    -- Group Loot is the dungeon policy, not a temporary FFA baseline to undo.
    local hold = saved.hold ~= "owned" and saved.hold or nil
    owner = nil
    request("dungeon", group, method, {hold = hold}, "dungeon", state.members, t)
end

function Loot.init(db)
    if saved then return end
    if type(db.autoLoot) ~= "table" then db.autoLoot = {} end
    saved = db.autoLoot
    local values = options()
    local names = {}
    if type(values.ffaNames) == "table" then
        for name, allow in pairs(values.ffaNames) do
            if type(name) == "string" and allow == true then
                local character, realm = name:match("^([^-]+)%-(.+)$")
                local key = normalName(character, realm)
                if key then names[key] = true end
            end
        end
    end
    values.ffaNames = names
    if saved.hold == "pending" or saved.hold == "owned" then saved.hold = "interrupted" end
    if saved.hold ~= "manual" and saved.hold ~= "failed" and saved.hold ~= "interrupted" then saved.hold = nil end
    -- Development logs are obsolete; keep only an interrupted-test warning if needed.
    if type(db.lootDiagnostics) == "table" and db.lootDiagnostics.pending then saved.hold = "interrupted" end
    db.lootDiagnostics = nil
    lastOptions = tostring(values.ffaFriends) .. ":" .. tostring(values.ffaCharacters)
    if saved.hold == "interrupted" then tell("A previous loot change needs review. Check loot manually; toggle an Auto FFA option to resume.") end
end
function Loot.status() return message end
function Loot.charactersText()
    local names = {}
    for name, allowed in pairs(options().ffaNames or {}) do if allowed then names[#names + 1] = name end end
    table.sort(names)
    return table.concat(names, "\n")
end
function Loot.setCharacters(input)
    if type(input) ~= "string" or #input > 16000 then return false, "Enter at most 100 names, one per line." end
    local names, count = {}, 0
    for line in (input .. "\n"):gmatch("([^\n]*)\n") do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" then
            local character, realm = line:match("^([^-]+)%-(.+)$")
            if not character then character, realm = line, read(GetNormalizedRealmName) end
            local key = normalName(character, realm)
            if not key then return false, "Use Name-Realm, one per line. A name alone uses your current realm." end
            if not names[key] then count = count + 1 end
            if count > 100 then return false, "The list is limited to 100 characters." end
            names[key] = true
        end
    end
    options().ffaNames = names
    Loot.settingsChanged()
    return true
end
function Loot.settingsChanged()
    if not saved then return end
    local current = tostring(options().ffaFriends) .. ":" .. tostring(options().ffaCharacters)
    if current ~= lastOptions then
        lastOptions, failedKey, stableKey = current, nil, nil
        dungeonFailed = nil
        -- Only a deliberate loot-option change resumes a paused policy.
        if not owner and not pending then saved.hold = nil; manualEvent, authorityLost = false, false end
    end
end
function Loot.event(event, ...)
    if not saved then return end
    if event == "ADDON_RESTRICTION_STATE_CHANGED" then
        local kind, state = ...
        if public(kind) and public(state) and type(kind) == "number" and type(state) == "number" then
            for _, name in ipairs(restrictions) do
                if kind == field(Enum and Enum.AddOnRestrictionType, name) then restrictionEvents[name] = state end
            end
        end
    elseif event == "GROUP_LEFT" or event == "GROUP_JOINED" or event == "GROUP_FORMED" then
        local category, guid = ...
        if not public(category) or category ~= (LE_PARTY_CATEGORY_HOME or 1) then return end
        if event == "GROUP_LEFT" then
            resetParty(); lastHome, awaitingLeave = false, true
        elseif text(guid) then
            if awaitingLeave or partyGUID and guid ~= partyGUID then resetParty() end
            partyGUID = guid
        end
    elseif event == "PARTY_LEADER_CHANGED" then
        if owner or pending then authorityLost = true end
        stableKey = nil
    elseif event == "PARTY_LOOT_METHOD_CHANGED" then
        local method = read(api("GetLootMethod"))
        if type(method) == "number" then
            if pending then
                -- An event can precede the server's new method becoming readable.
                if method == pending.target then pending.seenTarget = true
                elseif pending.seenTarget or method ~= pending.from then manualEvent = true end
            elseif owner then
                if method ~= enum("Freeforall") then manualEvent = true end
            elseif observedMethod ~= nil and method ~= observedMethod then manualEvent = true end
        end
    end
end
function Loot.tick()
    if not saved then return end
    local t = now()
    if t == nil then message = "Auto FFA unavailable: game timer is missing."; return end
    local state, reason, home, lostAuthority = context()
    local location = place()
    if location and location ~= lastPlace then stableKey, dungeonFailed, lastPlace = nil, nil, location end
    if home == false then
        if lastHome == true or saved.hold then resetParty() end
        lastHome = false
    elseif home == true then lastHome = true end
    if location ~= "dungeon" and not enabled() and not owner and not pending then
        observedMethod, stableKey, manualEvent, authorityLost = nil, nil, false, false
        message = saved.hold == "interrupted" and "Auto FFA is off. Check party loot manually after the interrupted change." or "Auto FFA is off."
        return
    end
    local method, masterParty = read(api("GetLootMethod"))
    if manualEvent then
        manualEvent = false
        pause("manual", "Paused after a manual loot change. Toggle an Auto FFA option to resume.")
    elseif authorityLost or (owner or pending) and lostAuthority then
        authorityLost = false
        pause("interrupted", "Party authority or identity changed. Check loot manually; toggle an Auto FFA option to resume.")
    elseif not owner and not pending and observedMethod ~= nil and type(method) == "number" and method ~= observedMethod and home == true then
        pause("manual", "Paused after a manual loot change. Toggle an Auto FFA option to resume.")
    elseif owner and type(method) == "number" and method ~= enum("Freeforall") and not pending then
        pause("manual", "Paused after a manual loot change. Toggle an Auto FFA option to resume.")
    end
    if type(method) == "number" then observedMethod = method end
    if not state then
        stableKey = nil
        if not saved.hold then message = (enabled() or location == "dungeon") and reason or "Auto FFA is off." end
        return
    end
    -- Finish a request already sent before choosing the current location's policy.
    if pollPending(method, masterParty, state.members, t) then return end
    if location == "dungeon" then dungeon(state, method, t); return end
    if location ~= "outdoor" then
        stableKey = nil; message = "Waiting for a known outdoor or dungeon location."; return
    end
    if saved.hold == "manual" or saved.hold == "interrupted" then
        message = saved.hold == "manual" and "Paused after a manual loot change. Toggle an Auto FFA option to resume." or
            "Check party loot manually; toggle an Auto FFA option to resume."
        return
    end
    local ready, evidence = false, "unknown"
    if state.members then ready, evidence = trusted(state.members) end
    ready = ready and enabled()
    local key = (state.identity or "unknown") .. ":" .. evidence .. ":" .. lastOptions
    if owner then
        if method ~= enum("Freeforall") then message = "Waiting for the current loot method."; return end
        if ready then message = "FFA active - all other party members are trusted."; return end
        if owner.master and not state.members then message = "Restore pending. Waiting for complete party identities."; return end
        local safe, why = idle()
        if not safe then message = "Restore pending. " .. why; return end
        if read(api("IsLootMethodAvailable"), owner.method) ~= true or type(api("SetLootMethod")) ~= "function" then
            pause("interrupted", "The previous loot method is unavailable. Check party loot manually.")
            return
        end
        request("restore", owner.method, method, owner, key, state.members, t)
        return
    end
    if not enabled() then stableKey = nil; message = "Auto FFA is off."; return end
    if not state.members then stableKey = nil; message = "Waiting for complete party identities."; return end
    if not ready then stableKey = nil; message = "Waiting: every other member must be connected and match an enabled option."; return end
    if saved.hold == "failed" then
        if failedKey == nil or failedKey == key then message = "FFA was not confirmed. Toggle an Auto FFA option to retry."; return end
        saved.hold = nil
    end
    local ffa = enum("Freeforall")
    if type(ffa) ~= "number" or type(api("SetLootMethod")) ~= "function" or read(api("IsLootMethodAvailable"), ffa) ~= true then
        stableKey = nil; message = "FFA is unavailable in this group."; return
    end
    if method == ffa then stableKey = nil; message = "FFA is already active; its setting remains under manual control."; return end
    local previous = capture(method, masterParty, state.members)
    if not previous or read(api("IsLootMethodAvailable"), method) ~= true then
        stableKey = nil; message = "Waiting: the current loot method cannot be safely restored."; return
    end
    local safe, why = idle(state.members)
    if not safe then stableKey = nil; message = why; return end
    if stableKey ~= key then stableKey, stableSince = key, t end
    if t - stableSince < 2 then message = "Checking the party before setting FFA."; return end
    request("apply", ffa, method, previous, key, state.members, t)
end
