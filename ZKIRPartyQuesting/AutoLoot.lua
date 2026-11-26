-- Leader-local loot policy. No chat, peer messages, or automatic quest actions.
local _, NS = ...
local Loot = {}
NS.AutoLoot = Loot

local saved
-- Runtime ownership and requests are never recovered from SavedVariables.
-- owner is the confirmed FFA baseline; pending is the one outstanding request.
local runtime = {manualEvent = false, authorityLost = false, awaitingLeave = false,
    restrictionEvents = {}, message = "Auto FFA is off."}
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
local function listedName(names, key)
    if names[key] == true then return key end
    -- Lua lower() only handles ASCII. Use the client's UTF-8 case comparison
    -- for existing saved spellings too; unavailable evidence grants no match.
    if type(strcmputf8i) ~= "function" then return nil end
    for name, allowed in pairs(names) do
        if allowed == true and read(strcmputf8i, name, key) == 0 then return name end
    end
    return nil
end
local function fullName(unit)
    local name, realm = read(UnitFullName, unit)
    if realm == nil or realm == "" then realm = read(GetNormalizedRealmName) end
    local key = normalName(name, realm)
    if key then return name .. "-" .. realm:gsub("%s", ""), key end
    return nil
end
local function tell(value)
    if runtime.message ~= value and DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
        pcall(DEFAULT_CHAT_FRAME.AddMessage, DEFAULT_CHAT_FRAME, "ZKIR Auto FFA: " .. value)
    end
    runtime.message = value
end
local function pause(reason, warning)
    runtime.owner, runtime.pending, runtime.stableKey = nil, nil, nil
    saved.hold = reason
    if warning then tell(warning) end
end
local function resetParty()
    runtime.owner, runtime.pending, runtime.stableKey = nil, nil, nil
    runtime.failedKey, runtime.observedMethod, runtime.partyGUID = nil, nil, nil
    runtime.manualEvent, runtime.authorityLost, runtime.awaitingLeave = false, false, false
    runtime.lastPlace, runtime.dungeonFailed = nil, nil
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
                runtime.restrictionEvents[name] == 1 or runtime.restrictionEvents[name] == 2 then
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
        if not match and options().ffaCharacters == true and listedName(options().ffaNames, member.key) then match = true end
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
    runtime.owner, runtime.pending, runtime.stableKey = nil, nil, nil
    runtime.dungeonFailed = not confirmed
    saved.hold = hold or (not confirmed and "interrupted" or nil)
    if confirmed then runtime.message = "Dungeon: Group Loot."
    else tell("Dungeon Group Loot was not confirmed. Check loot manually; toggle an Auto FFA option to retry.") end
end
local function request(change, members, t)
    local master
    if change.kind == "restore" then
        local valid
        master, valid = masterName(change.baseline, members)
        if not valid then
            pause("interrupted", "Previous master looter is unavailable. Choose loot manually.")
            return
        end
    end
    change.deadline = t + 5
    runtime.pending = change
    saved.hold = "pending"
    -- Authority and state were checked in this tick. Event callbacks only observe.
    local success = read(api("SetLootMethod"), change.target, master)
    if success ~= true then
        if change.kind == "dungeon" then dungeonResult(false, change.resumeHold); return end
        runtime.failedKey = change.key
        pause(change.kind == "restore" and "interrupted" or "failed", "Loot change was not accepted. Check loot manually; toggle an Auto FFA option to retry.")
        return
    end
    runtime.message = change.kind == "dungeon" and "Setting dungeon Group Loot; waiting for confirmation." or
        (change.kind == "apply" and "Setting FFA; waiting for confirmation." or "Restoring the previous loot method.")
end
local function completeRequest(change)
    runtime.pending = nil
    if change.kind == "apply" then
        runtime.owner = change.baseline
        saved.hold = "owned"
        runtime.message = "FFA confirmed; checking the current party."
    elseif change.kind == "dungeon" then
        dungeonResult(true, change.resumeHold)
    else
        runtime.owner, saved.hold, runtime.stableKey = nil, nil, nil
        runtime.message = "Previous loot method restored."
    end
end
local function pollPending(method, masterParty, members, t)
    local change = runtime.pending
    if not change then return false end
    local confirmed = method == change.target
    if confirmed and change.kind == "restore" and change.baseline.master then
        local member = members and type(masterParty) == "number" and members[masterParty + 1]
        confirmed = member and member.guid == change.baseline.master
    end
    if confirmed then
        completeRequest(change)
    elseif t >= change.deadline then
        if change.kind == "dungeon" then dungeonResult(false, change.resumeHold); return true end
        runtime.failedKey = change.key
        local restoration = change.kind == "restore"
        pause(restoration and "interrupted" or "failed", restoration and
            "Restoration was not confirmed. Check party loot manually." or
            "FFA was not confirmed. Check loot; toggle an Auto FFA option to retry.")
    end
    return true
end

local function dungeon(state, method, t)
    runtime.stableKey = nil
    local count, group = read(GetNumSubgroupMembers), enum("Group")
    if type(count) ~= "number" or count < 1 or count > 4 or count % 1 ~= 0 then
        runtime.message = "Dungeon: waiting for a party of 2-5."; return
    end
    if type(method) ~= "number" or type(group) ~= "number" then
        runtime.message = "Dungeon: waiting for loot information."; return
    end
    if method == group then
        runtime.owner, runtime.dungeonFailed = nil, nil
        if saved.hold == "owned" then saved.hold = nil end
        runtime.message = "Dungeon: Group Loot."; return
    end
    if runtime.dungeonFailed then
        runtime.message = "Dungeon Group Loot failed. Check loot manually; toggle an Auto FFA option to retry."; return
    end
    local safe, why = idle()
    if not safe then runtime.message = "Dungeon Group Loot pending. " .. why; return end
    if type(api("SetLootMethod")) ~= "function" or read(api("IsLootMethodAvailable"), group) ~= true then
        runtime.message = "Dungeon Group Loot is unavailable. Check loot manually."; return
    end
    -- Group Loot is the dungeon policy, not a temporary FFA baseline to undo.
    local hold = saved.hold ~= "owned" and saved.hold or nil
    runtime.owner = nil
    request({kind = "dungeon", target = group, from = method, resumeHold = hold}, state.members, t)
end

local function outdoor(state, method, masterParty, t)
    if saved.hold == "manual" or saved.hold == "interrupted" then
        runtime.message = saved.hold == "manual" and "Paused after a manual loot change. Toggle an Auto FFA option to resume." or
            "Check party loot manually; toggle an Auto FFA option to resume."
        return
    end
    local ready, evidence = false, "unknown"
    if state.members then ready, evidence = trusted(state.members) end
    ready = ready and enabled()
    local key = (state.identity or "unknown") .. ":" .. evidence .. ":" .. runtime.lastOptions
    if runtime.owner then
        if method ~= enum("Freeforall") then runtime.message = "Waiting for the current loot method."; return end
        if ready then runtime.message = "FFA active - all other party members are trusted."; return end
        if runtime.owner.master and not state.members then runtime.message = "Restore pending. Waiting for complete party identities."; return end
        local safe, why = idle()
        if not safe then runtime.message = "Restore pending. " .. why; return end
        if read(api("IsLootMethodAvailable"), runtime.owner.method) ~= true or type(api("SetLootMethod")) ~= "function" then
            pause("interrupted", "The previous loot method is unavailable. Check party loot manually.")
            return
        end
        request({kind = "restore", target = runtime.owner.method, from = method,
            baseline = runtime.owner, key = key}, state.members, t)
        return
    end
    if not enabled() then runtime.stableKey = nil; runtime.message = "Auto FFA is off."; return end
    if not state.members then runtime.stableKey = nil; runtime.message = "Waiting for complete party identities."; return end
    if not ready then runtime.stableKey = nil; runtime.message = "Waiting: every other member must be connected and match an enabled option."; return end
    if saved.hold == "failed" then
        if runtime.failedKey == nil or runtime.failedKey == key then runtime.message = "FFA was not confirmed. Toggle an Auto FFA option to retry."; return end
        saved.hold = nil
    end
    local ffa = enum("Freeforall")
    if type(ffa) ~= "number" or type(api("SetLootMethod")) ~= "function" or read(api("IsLootMethodAvailable"), ffa) ~= true then
        runtime.stableKey = nil; runtime.message = "FFA is unavailable in this group."; return
    end
    if method == ffa then runtime.stableKey = nil; runtime.message = "FFA is already active; its setting remains under manual control."; return end
    local previous = capture(method, masterParty, state.members)
    if not previous or read(api("IsLootMethodAvailable"), method) ~= true then
        runtime.stableKey = nil; runtime.message = "Waiting: the current loot method cannot be safely restored."; return
    end
    local safe, why = idle(state.members)
    if not safe then runtime.stableKey = nil; runtime.message = why; return end
    if runtime.stableKey ~= key then runtime.stableKey, runtime.stableSince = key, t end
    if t - runtime.stableSince < 2 then runtime.message = "Checking the party before setting FFA."; return end
    request({kind = "apply", target = ffa, from = method, baseline = previous, key = key}, state.members, t)
end

function Loot.init(db)
    if saved then return end
    if type(db.autoLoot) ~= "table" then db.autoLoot = {} end
    saved = db.autoLoot
    local values = options()
    local names = {}
    if type(values.ffaNames) == "table" then
        local spellings = {}
        for name, allow in pairs(values.ffaNames) do
            if type(name) == "string" and allow == true then spellings[#spellings + 1] = name end
        end
        table.sort(spellings)
        for _, name in ipairs(spellings) do
            local character, realm = name:match("^([^-]+)%-(.+)$")
            local key = normalName(character, realm)
            if key and not listedName(names, key) then names[key] = true end
        end
    end
    values.ffaNames = names
    if saved.hold == "pending" or saved.hold == "owned" then saved.hold = "interrupted" end
    if saved.hold ~= "manual" and saved.hold ~= "failed" and saved.hold ~= "interrupted" then saved.hold = nil end
    -- Development logs are obsolete; keep only an interrupted-test warning if needed.
    if type(db.lootDiagnostics) == "table" and db.lootDiagnostics.pending then saved.hold = "interrupted" end
    db.lootDiagnostics = nil
    runtime.lastOptions = tostring(values.ffaFriends) .. ":" .. tostring(values.ffaCharacters)
    if saved.hold == "interrupted" then tell("A previous loot change needs review. Check loot manually; toggle an Auto FFA option to resume.") end
end
function Loot.status() return runtime.message end
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
            if not listedName(names, key) then count = count + 1; names[key] = true end
            if count > 100 then return false, "The list is limited to 100 characters." end
        end
    end
    options().ffaNames = names
    Loot.settingsChanged()
    return true
end
function Loot.settingsChanged()
    if not saved then return end
    local current = tostring(options().ffaFriends) .. ":" .. tostring(options().ffaCharacters)
    if current ~= runtime.lastOptions then
        runtime.lastOptions, runtime.failedKey, runtime.stableKey = current, nil, nil
        runtime.dungeonFailed = nil
        -- Only a deliberate loot-option change resumes a paused policy.
        if not runtime.owner and not runtime.pending then saved.hold = nil; runtime.manualEvent, runtime.authorityLost = false, false end
    end
end
function Loot.event(event, ...)
    if not saved then return end
    if event == "ADDON_RESTRICTION_STATE_CHANGED" then
        local kind, state = ...
        if public(kind) and public(state) and type(kind) == "number" and type(state) == "number" then
            for _, name in ipairs(restrictions) do
                if kind == field(Enum and Enum.AddOnRestrictionType, name) then runtime.restrictionEvents[name] = state end
            end
        end
    elseif event == "GROUP_LEFT" or event == "GROUP_JOINED" or event == "GROUP_FORMED" then
        local category, guid = ...
        if not public(category) or category ~= (LE_PARTY_CATEGORY_HOME or 1) then return end
        if event == "GROUP_LEFT" then
            resetParty(); runtime.lastHome, runtime.awaitingLeave = false, true
        elseif text(guid) then
            if runtime.awaitingLeave or runtime.partyGUID and guid ~= runtime.partyGUID then resetParty() end
            runtime.partyGUID = guid
        end
    elseif event == "PARTY_LEADER_CHANGED" then
        if runtime.owner or runtime.pending then runtime.authorityLost = true end
        runtime.stableKey = nil
    elseif event == "PARTY_LOOT_METHOD_CHANGED" then
        local method = read(api("GetLootMethod"))
        if type(method) == "number" then
            local change = runtime.pending
            if change then
                -- An event can precede the server's new method becoming readable.
                if method == change.target then change.seenTarget = true
                elseif change.seenTarget or method ~= change.from then runtime.manualEvent = true end
            elseif runtime.owner then
                if method ~= enum("Freeforall") then runtime.manualEvent = true end
            elseif runtime.observedMethod ~= nil and method ~= runtime.observedMethod then runtime.manualEvent = true end
        end
    end
end
local function observeAuthority(method, home, lostAuthority)
    if runtime.manualEvent then
        runtime.manualEvent = false
        pause("manual", "Paused after a manual loot change. Toggle an Auto FFA option to resume.")
    elseif runtime.authorityLost or (runtime.owner or runtime.pending) and lostAuthority then
        runtime.authorityLost = false
        pause("interrupted", "Party authority or identity changed. Check loot manually; toggle an Auto FFA option to resume.")
    elseif not runtime.owner and not runtime.pending and runtime.observedMethod ~= nil and
        type(method) == "number" and method ~= runtime.observedMethod and home == true then
        pause("manual", "Paused after a manual loot change. Toggle an Auto FFA option to resume.")
    elseif runtime.owner and type(method) == "number" and method ~= enum("Freeforall") and not runtime.pending then
        pause("manual", "Paused after a manual loot change. Toggle an Auto FFA option to resume.")
    end
    if type(method) == "number" then runtime.observedMethod = method end
end

function Loot.tick()
    if not saved then return end
    local t = now()
    if t == nil then runtime.message = "Auto FFA unavailable: game timer is missing."; return end
    local state, reason, home, lostAuthority = context()
    local location = place()
    if location and location ~= runtime.lastPlace then
        runtime.stableKey, runtime.dungeonFailed, runtime.lastPlace = nil, nil, location
    end
    if home == false then
        if runtime.lastHome == true or saved.hold then resetParty() end
        runtime.lastHome = false
    elseif home == true then runtime.lastHome = true end
    if location ~= "dungeon" and not enabled() and not runtime.owner and not runtime.pending then
        runtime.observedMethod, runtime.stableKey, runtime.manualEvent, runtime.authorityLost = nil, nil, false, false
        runtime.message = saved.hold == "interrupted" and "Auto FFA is off. Check party loot manually after the interrupted change." or "Auto FFA is off."
        return
    end
    local method, masterParty = read(api("GetLootMethod"))
    observeAuthority(method, home, lostAuthority)
    if not state then
        runtime.stableKey = nil
        if not saved.hold then runtime.message = (enabled() or location == "dungeon") and reason or "Auto FFA is off." end
        return
    end
    -- Finish a request already sent before choosing the current location's policy.
    if pollPending(method, masterParty, state.members, t) then return end
    if location == "dungeon" then dungeon(state, method, t); return end
    if location ~= "outdoor" then
        runtime.stableKey = nil; runtime.message = "Waiting for a known outdoor or dungeon location."; return
    end
    outdoor(state, method, masterParty, t)
end
