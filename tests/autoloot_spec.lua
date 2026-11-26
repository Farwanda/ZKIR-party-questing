-- Production Auto FFA policy with mocked public APIs, never a live loot change.
local passed, checks = 0, 0
local function expect(value, message) checks = checks + 1; assert(value, message) end
local function test(name, fn)
    local ok, err = pcall(fn)
    assert(ok, name .. ": " .. tostring(err))
    passed = passed + 1
end
local function fixture(db)
    db = db or {}; db.settings = type(db.settings) == "table" and db.settings or {}
    local state = {time = 0, method = 3, master = 0, count = 1, leader = true, home = true,
        instance = false, inInstance = false, instanceType = "none", raid = false, combat = false, loot = 0, bn = true,
        members = {player = {guid = "Player-1-SELF", name = "Alice", realm = "Realm", connected = true},
            party1 = {guid = "Player-1-BOB", name = "Bob", realm = "Realm", connected = true}},
        friends = {["Player-1-BOB"] = true}}
    local env = setmetatable({}, {__index = _G})
    local ns, calls, lookups, notices = {Settings = {values = db.settings}}, {}, {}, {}
    env.GetTime = function() return state.time end
    env.issecretvalue = function(v) return type(v) == "table" and rawget(v, "secret") == true end
    env.Enum = {LootMethod = {Freeforall = 0, Group = 3, Roundrobin = 1, Masterlooter = 2,
        Needbeforegreed = 4, Personal = 5}}
    env.IsInRaid = function() return state.raid end
    env.IsInInstance = function() return state.inInstance, state.instanceType end
    env.IsInGroup = function(category) if category == 1 then return state.home end; return state.instance end
    env.GetNumSubgroupMembers = function() return state.count end
    env.UnitGUID = function(unit) return state.members[unit] and state.members[unit].guid end
    env.UnitFullName = function(unit)
        local member = state.members[unit]; if member then return member.name, member.realm end
    end
    env.GetNormalizedRealmName = function() return "Realm" end
    env.UnitIsConnected = function(unit) return state.members[unit] and state.members[unit].connected end
    env.UnitIsGroupLeader = function(unit) return unit == "player" and state.leader or false end
    env.UnitAffectingCombat = function(unit) return state.members[unit] and state.members[unit].combat or false end
    env.InCombatLockdown = function() return state.combat end
    env.GetNumLootItems = function() return state.loot end
    env.C_PartyInfo = {
        GetLootMethod = function() return state.method, state.master, 0 end,
        IsLootMethodAvailable = function() return true end,
        SetLootMethod = function(method, master)
            calls[#calls + 1] = {method = method, master = master, time = state.time}
            if state.throwSetter then error("setter unavailable") end
            if not state.reject then
                state.method = method
                if method == 2 and master then
                    for unit, member in pairs(state.members) do
                        if member.name .. "-" .. member.realm == master then
                            state.master = unit == "player" and 0 or tonumber(unit:match("party(%d+)"))
                        end
                    end
                end
            end
            return not state.reject
        end,
    }
    env.BNConnected = function() return state.bn end
    env.C_BattleNet = {
        IsBattleNetFriendsListSupported = function() return true end,
        IsBattleNetFriendsListEnabled = function() return true end,
        GetAccountInfoByGUID = function(guid)
            lookups[#lookups + 1] = guid
            return {isFriend = state.friends[guid], bnetAccountID = 123,
                gameAccountInfo = {playerGuid = "Player-1-OTHERALT"}}
        end,
    }
    env.DEFAULT_CHAT_FRAME = {AddMessage = function(_, message) notices[#notices + 1] = message end}
    env.SendChatMessage = function() error("Auto FFA must not send chat") end
    env.C_ChatInfo = {SendAddonMessage = function() error("Auto FFA must not send addon messages") end}
    for _, name in ipairs({"API", "Widgets", "Settings", "AutoLoot"}) do
        local chunk = assert(loadfile("ZKIRPartyQuesting/" .. name .. ".lua"))
        setfenv(chunk, env); chunk("ZKIRPartyQuesting", ns)
    end
    ns.Settings.init(db)
    ns.AutoLoot.init(db)
    local function advance(seconds)
        for _ = 1, seconds * 2 do state.time = state.time + 0.5; ns.AutoLoot.tick() end
    end
    local function enable(friends, characters)
        ns.Settings.values.ffaFriends, ns.Settings.values.ffaCharacters = friends == true, characters == true
        ns.AutoLoot.settingsChanged()
    end
    return {loot = ns.AutoLoot, state = state, env = env, db = db, values = ns.Settings.values,
        calls = calls, lookups = lookups, notices = notices, advance = advance, enable = enable}
end
local function contains(value, part) return value:find(part, 1, true) ~= nil end
local function extra(c, index, name, friend)
    local guid = "Player-1-" .. name
    c.state.members["party" .. index] = {guid = guid, name = name, realm = "Realm", connected = true}
    c.state.count = math.max(c.state.count, index)
    c.state.friends[guid] = friend
end
local function dungeon(c, inside)
    c.state.inInstance, c.state.instanceType = inside, inside and "party" or "none"
    c.loot.event("PLAYER_ENTERING_WORLD")
end

test("both policies default off and never change loot or send messages", function()
    local c = fixture(); c.advance(30)
    expect(c.values.ffaFriends == false and c.values.ffaCharacters == false, "both flags are opt-in")
    expect(#c.calls == 0 and contains(c.loot.status(), "off"), "disabled policy stays read-only")
    c = fixture({settings = {ffaFriends = "true", ffaCharacters = 1}}); c.advance(10)
    expect(c.values.ffaFriends == false and c.values.ffaCharacters == false and #c.calls == 0,
        "corrupt saved options cannot enable loot writes")
end)

test("disabled policy ignores loot changes without local warnings or recovery state", function()
    local c = fixture(); c.advance(1)
    for _, method in ipairs({1, 0, 4, 3}) do
        c.state.method = method; c.loot.event("PARTY_LOOT_METHOD_CHANGED")
        c.loot.event("GROUP_ROSTER_UPDATE"); c.advance(1)
    end
    expect(#c.calls == 0 and #c.notices == 0 and not c.db.autoLoot.hold,
        "disabled policy must neither modify loot nor report manual interventions")
    expect(contains(c.loot.status(), "off"), "disabled status stays off")
end)

test("explicit character names normalize realms, deduplicate, persist and validate atomically", function()
    local c = fixture()
    expect(c.loot.setCharacters("  Bob-Realm\nBOB-Realm\nCarla-Other Realm\n"), "valid list accepted")
    expect(c.values.ffaNames["bob-realm"] and c.values.ffaNames["carla-otherrealm"], "names use exact normalized Name-Realm keys")
    expect(c.loot.charactersText() == "bob-realm\ncarla-otherrealm", "editor round trip is deterministic")
    local before = c.loot.charactersText()
    for _, input in ipairs({"Bob-Realm\nBad Name-Realm", "Bob-Realm\nBad|Code-Realm", "-Realm", string.rep("A", 16001)}) do
        local ok, reason = c.loot.setCharacters(input)
        expect(not ok and type(reason) == "string" and c.loot.charactersText() == before,
            "invalid lists preserve the old complete map")
    end
    local reloaded = fixture(c.db)
    expect(reloaded.loot.charactersText() == before, "allowlist persists")
    expect(c.loot.setCharacters("Bob") and c.values.ffaNames["bob-realm"], "bare name expands only to current known realm")
    c.env.GetNormalizedRealmName = nil
    expect(not c.loot.setCharacters("Carla"), "bare names need a known local realm")
    expect(c.loot.setCharacters(""), "empty list is allowed")
    expect(next(c.values.ffaNames) == nil, "empty list removes prior names")
end)

test("friend policy uses each other member's exact GUID and excludes self from friendship", function()
    local c = fixture(); c.enable(true, false)
    c.advance(2); expect(#c.calls == 0, "trust must remain stable for two seconds")
    c.advance(1)
    expect(#c.calls == 1 and c.calls[1].method == 0 and c.state.method == 0, "trusted party gets one FFA request")
    for _, guid in ipairs(c.lookups) do expect(guid == "Player-1-BOB", "self or guessed alt GUIDs are never friend queries") end
    c.advance(30); expect(#c.calls == 1, "stable trusted party does not repeat setter calls")
end)

test("every other member must match the union of enabled policies", function()
    local c = fixture(); extra(c, 2, "Carla", false); extra(c, 3, "Dain", true); extra(c, 4, "Elya", false)
    expect(c.loot.setCharacters("Carla-Realm\nElya-Realm"), "explicit exceptions saved")
    c.enable(true, true); c.advance(4)
    expect(#c.calls == 1 and c.state.method == 0, "friend-or-character matches can mix within a five-person party")
    c = fixture(); extra(c, 2, "Carla", false); c.enable(true, false); c.advance(10)
    expect(#c.calls == 0, "one untrusted party member blocks activation")
    c.loot.setCharacters("Carla-Realm"); c.advance(5)
    expect(#c.calls == 0, "disabled character policy does not grant trust")
    c.enable(true, true); c.advance(4)
    expect(#c.calls == 1, "enabling the explicit alternative allows the entire trusted party")
end)

test("character-only policy is realm-specific and does not depend on Battle.net", function()
    local c = fixture(); c.state.bn = false; c.env.C_BattleNet.GetAccountInfoByGUID = nil
    c.loot.setCharacters("Bob-OtherRealm"); c.enable(false, true); c.advance(5)
    expect(#c.calls == 0, "same character spelling on a different realm is untrusted")
    c.loot.setCharacters("bOb-rEaLm"); c.advance(4)
    expect(#c.calls == 1 and #c.lookups == 0, "explicit current character works with Battle.net offline")
end)

test("missing, secret or false friendship evidence never activates friend-only policy", function()
    local variants = {
        function(c) c.env.BNConnected = nil end,
        function(c) c.state.bn = false end,
        function(c) c.env.C_BattleNet.GetAccountInfoByGUID = nil end,
        function(c) c.env.C_BattleNet.GetAccountInfoByGUID = function() error("private account error") end end,
        function(c) c.env.C_BattleNet.GetAccountInfoByGUID = function() return {secret = true} end end,
        function(c) c.env.C_BattleNet.GetAccountInfoByGUID = function() return {isFriend = {secret = true}} end end,
        function(c) c.env.C_BattleNet.GetAccountInfoByGUID = function() return {isFriend = false} end end,
        function(c) c.env.C_BattleNet.GetAccountInfoByGUID = function() return {} end end,
        function(c) c.env.C_BattleNet.IsBattleNetFriendsListEnabled = function() return false end end,
    }
    for index, alter in ipairs(variants) do
        local c = fixture(); alter(c); c.enable(true, false); c.advance(10)
        expect(#c.calls == 0, "unverified friend evidence cannot authorize activation: " .. index)
        c.loot.setCharacters("Bob-Realm"); c.enable(true, true); c.advance(4)
        expect(#c.calls == 1, "explicit character independently supplies trust: " .. index)
    end
end)

test("Battle.net disconnection revokes friend-only trust and restores owned baseline", function()
    local c = fixture(); c.enable(true, false); c.advance(4)
    c.state.bn = false; c.loot.event("BN_DISCONNECTED"); c.advance(2)
    expect(#c.calls == 2 and c.calls[2].method == 3 and c.state.method == 3, "lost friend evidence restores Group Loot")
    c.advance(20); expect(#c.calls == 2, "offline Battle.net does not trigger repeated writes")
    c = fixture(); c.loot.setCharacters("Bob-Realm"); c.enable(true, true); c.advance(4)
    c.state.bn = false; c.loot.event("BN_DISCONNECTED"); c.advance(5)
    expect(#c.calls == 1 and c.state.method == 0, "explicit character trust survives Battle.net disconnection")
end)

test("untrusted roster replacement restores owned FFA and cannot inherit earlier trust", function()
    local c = fixture(); c.enable(true, false); c.advance(4)
    c.state.members.party1 = {name = "Mallory", realm = "Realm", guid = "Player-1-MALLORY", connected = true}
    c.loot.event("GROUP_ROSTER_UPDATE"); c.advance(3)
    expect(#c.calls == 2 and c.state.method == 3, "replacement GUID must provide fresh trust")
    c = fixture(); c.loot.setCharacters("Bob-Realm"); c.enable(false, true); c.advance(1.5)
    c.state.members.party1.name = "Mallory"; c.loot.event("GROUP_ROSTER_UPDATE"); c.advance(6)
    expect(#c.calls == 0, "changed name cannot borrow allowlist membership from the same GUID")
end)

test("unchanged roster notifications preserve stabilization while a new identity restarts it", function()
    local c = fixture(); c.enable(true, false)
    for _ = 1, 5 do c.loot.event("GROUP_ROSTER_UPDATE"); c.advance(0.5) end
    expect(#c.calls == 1, "ordinary roster notifications cannot indefinitely postpone stable trust")
    c = fixture(); c.enable(true, false); c.advance(1.5)
    c.state.members.party1.guid = "Player-1-BOBNEW"
    c.state.friends["Player-1-BOBNEW"] = true
    c.loot.event("GROUP_ROSTER_UPDATE"); c.advance(1)
    expect(#c.calls == 0, "replacement identity needs its own stable interval")
    c.advance(2); expect(#c.calls == 1, "replacement can qualify after fresh stable evidence")
end)

test("ordinary party authority and complete identities are required", function()
    local variants = {
        function(c) c.state.leader = false end,
        function(c) c.state.count = 0 end,
        function(c) c.state.count = 5 end,
        function(c) c.state.raid = true end,
        function(c) c.state.home = false end,
        function(c) c.state.instance = true end,
        function(c) c.state.members.party1.connected = false end,
        function(c) c.state.members.party1.connected = nil end,
        function(c) c.state.members.party1.guid = nil end,
        function(c) c.state.members.party1.guid = {secret = true} end,
        function(c) c.state.members.party1.guid = c.state.members.player.guid end,
        function(c) c.state.members.party1.name = {secret = true} end,
        function(c) c.env.UnitFullName = function() error("identity unavailable") end end,
        function(c) c.env.UnitIsConnected = nil end,
        function(c) c.env.GetTime = nil end,
        function(c) c.env.C_PartyInfo.GetLootMethod = nil end,
        function(c) c.env.C_PartyInfo.GetLootMethod = function() return {secret = true} end end,
        function(c) c.env.C_PartyInfo.SetLootMethod = nil end,
    }
    for index, alter in ipairs(variants) do
        local c = fixture(); alter(c); c.enable(true, false); c.advance(10)
        expect(#c.calls == 0, "unsafe or uncertain context is read-only: " .. index)
    end
end)

test("combat, looting and active or unknown restrictions defer activation", function()
    local variants = {
        function(c) c.state.combat = true end,
        function(c) c.state.members.party1.combat = true end,
        function(c) c.state.loot = 1 end,
        function(c) c.env.GetNumLootItems = nil end,
        function(c) c.env.UnitAffectingCombat = nil end,
        function(c) c.env.LootFrame = {IsShown = function() return true end} end,
        function(c)
            c.env.Enum.AddOnRestrictionType = {Combat = 1, Encounter = 2, ChallengeMode = 3, PvPMatch = 4, Map = 5}
            c.env.C_RestrictedActions = {GetAddOnRestrictionState = function() return 2 end}
        end,
        function(c) c.env.C_RestrictedActions = {GetAddOnRestrictionState = function() return {secret = true} end} end,
    }
    for index, alter in ipairs(variants) do
        local c = fixture(); alter(c); c.enable(true, false); c.advance(8)
        expect(#c.calls == 0, "unsafe write timing is deferred: " .. index)
    end
end)

test("restriction event blocks a write before the getter reflects activation", function()
    local c = fixture()
    c.env.Enum.AddOnRestrictionType = {Combat = 1, Encounter = 2, ChallengeMode = 3, PvPMatch = 4, Map = 5}
    c.env.C_RestrictedActions = {GetAddOnRestrictionState = function() return 0 end}
    c.enable(true, false); c.advance(1.5)
    c.loot.event("ADDON_RESTRICTION_STATE_CHANGED", 1, 1); c.advance(5)
    expect(#c.calls == 0, "activation event immediately revokes safe write timing")
    c.loot.event("ADDON_RESTRICTION_STATE_CHANGED", 1, 0); c.advance(3)
    expect(#c.calls == 1, "cleared restrictions allow a new stable interval")
end)

test("each supported prior loot method is restored exactly without changing thresholds", function()
    for _, method in ipairs({1, 3, 4}) do
        local c = fixture(); c.state.method = method
        c.env.SetLootThreshold = function() error("threshold must remain untouched") end
        c.enable(true, false); c.advance(4); c.enable(false, false); c.advance(2)
        expect(#c.calls == 2 and c.calls[1].method == 0 and c.calls[2].method == method and c.state.method == method,
            "restore the exact captured baseline: " .. method)
    end
end)

test("master loot restores the same person's current full name, never a reused party slot", function()
    local c = fixture(); extra(c, 2, "Carla", true); c.state.method, c.state.master = 2, 1
    c.enable(true, false); c.advance(4)
    c.state.members.party1, c.state.members.party2 = c.state.members.party2, c.state.members.party1
    c.loot.event("GROUP_ROSTER_UPDATE"); c.enable(false, false); c.advance(2)
    expect(#c.calls == 2 and c.calls[2].method == 2 and c.calls[2].master == "Bob-Realm",
        "restoration follows captured master GUID across party slot reorder")
    c = fixture(); c.state.method, c.state.master = 2, nil; c.enable(true, false); c.advance(6)
    expect(#c.calls == 0, "unknown master identity prevents FFA activation")
    c = fixture(); c.state.method, c.state.master = 2, 1; c.enable(true, false); c.advance(4)
    c.state.members.party1 = {name = "Mallory", realm = "Realm", guid = "Player-1-MALLORY", connected = true}
    c.enable(false, false); c.advance(5)
    expect(#c.calls == 1 and c.db.autoLoot.hold == "interrupted", "departed master requires manual recovery")
end)

test("master loot restoration requires observing the original master GUID", function()
    local c = fixture(); c.state.method, c.state.master = 2, 1
    c.enable(true, false); c.advance(4)
    c.env.C_PartyInfo.SetLootMethod = function(method, master)
        c.calls[#c.calls + 1] = {method = method, master = master, time = c.state.time}
        c.state.method, c.state.master = method, 0 -- API accepted but restored the wrong person
        return true
    end
    c.enable(false, false); c.advance(10)
    expect(#c.calls == 2 and c.calls[2].master == "Bob-Realm", "request names the captured master")
    expect(c.db.autoLoot.hold == "interrupted" and contains(c.loot.status(), "manually"),
        "wrong-master readback cannot be reported as successful restoration")
end)

test("existing manual FFA and unsupported baselines remain unowned", function()
    for _, method in ipairs({0, 5, 99}) do
        local c = fixture(); c.state.method = method; c.enable(true, false); c.advance(5)
        c.state.friends["Player-1-BOB"] = false; c.enable(false, false); c.advance(5)
        expect(#c.calls == 0 and c.state.method == method, "cannot claim or restore a method the addon did not change: " .. method)
    end
end)

test("manual changes pause the same party despite noisy roster and other settings changes", function()
    local c = fixture(); c.enable(true, false); c.advance(4)
    c.state.method = 1; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(1)
    expect(c.db.autoLoot.hold == "manual" and #c.calls == 1, "manual choice pauses automatic policy")
    for _ = 1, 5 do c.loot.event("GROUP_ROSTER_UPDATE"); c.advance(2) end
    c.values.sound = false; c.loot.settingsChanged(); c.loot.setCharacters("Bob-Realm"); c.advance(8)
    expect(#c.calls == 1 and c.state.method == 1, "unrelated settings and allowlist edits cannot clear manual pause")
    c.enable(false, false); c.advance(1); c.enable(true, false); c.advance(4)
    expect(#c.calls == 2 and c.state.method == 0, "explicit Auto FFA toggle re-enables the policy")
end)

test("manual selection away and back between ticks still pauses the policy", function()
    local c = fixture(); c.enable(true, false); c.advance(4)
    c.state.method = 1; c.loot.event("PARTY_LOOT_METHOD_CHANGED")
    c.state.method = 0; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(10)
    expect(#c.calls == 1 and c.db.autoLoot.hold == "manual" and c.state.method == 0,
        "event-time manual intervention cannot disappear between polls")
end)

test("leadership loss or brief transfer prevents a stale restore", function()
    for _, returnLeadership in ipairs({false, true}) do
        local c = fixture(); c.enable(true, false); c.advance(4)
        c.state.leader = false; c.loot.event("PARTY_LEADER_CHANGED")
        if returnLeadership then c.state.leader = true; c.loot.event("PARTY_LEADER_CHANGED") end
        c.state.bn = false; c.advance(10)
        expect(#c.calls == 1 and c.db.autoLoot.hold == "interrupted", "loss of authority revokes owned restoration")
    end
end)

test("failed setter calls and unconfirmed restores do not spam", function()
    for _, failure in ipairs({"reject", "throwSetter"}) do
        local c = fixture(); c.state[failure] = true; c.enable(true, false); c.advance(30)
        expect(#c.calls == 1 and c.db.autoLoot.hold == "failed", "failed activation is attempted only once")
        c.loot.event("GROUP_ROSTER_UPDATE"); c.advance(20)
        expect(#c.calls == 1, "unchanged roster events never retry a failed write")
    end
    local c = fixture(); c.enable(true, false); c.advance(4); c.state.reject = true
    c.enable(false, false); c.advance(30)
    expect(#c.calls == 2 and c.db.autoLoot.hold == "interrupted", "failed restoration stays paused after one request")
    expect(contains(c.loot.status(), "off") and contains(c.loot.status(), "manually"),
        "disabled policy must retain the unresolved restoration warning")
end)

test("rejected calls cannot acquire ownership from a later external FFA selection", function()
    for _, failure in ipairs({"reject", "throwSetter", "nil"}) do
        local c = fixture()
        if failure == "nil" then
            c.env.C_PartyInfo.SetLootMethod = function(method)
                c.calls[#c.calls + 1] = {method = method, time = c.state.time}
                return nil
            end
        else c.state[failure] = true end
        c.enable(true, false); c.advance(3)
        expect(#c.calls == 1 and c.db.autoLoot.hold == "failed", "rejected call pauses immediately: " .. failure)
        c.state.method = 0; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(1)
        c.state.bn = false; c.loot.event("BN_DISCONNECTED"); c.advance(10)
        expect(#c.calls == 1 and c.state.method == 0 and c.db.autoLoot.hold ~= "owned",
            "later manual FFA remains unowned after rejection: " .. failure)
    end
end)

test("incomplete roster restores only an already-owned simple baseline under current leadership", function()
    local c = fixture(); c.enable(true, false); c.advance(4)
    c.state.members.party1.guid = nil; c.loot.event("GROUP_ROSTER_UPDATE"); c.advance(2)
    expect(#c.calls == 2 and c.calls[2].method == 3 and c.state.method == 3,
        "uncertain roster revokes trust and restores a known simple baseline")
    c.advance(10); expect(#c.calls == 2, "incomplete roster cannot authorize reactivation")
    c = fixture(); c.state.method, c.state.master = 2, 1; c.enable(true, false); c.advance(4)
    c.state.members.party1.guid = nil; c.loot.event("GROUP_ROSTER_UPDATE"); c.advance(5)
    expect(#c.calls == 1, "unknown roster cannot resolve the previous master looter")
    c = fixture(); c.enable(true, false); c.advance(4)
    c.state.members.party1.guid = nil; c.state.leader = false
    c.loot.event("PARTY_LEADER_CHANGED"); c.advance(5)
    expect(#c.calls == 1, "incomplete roster never bypasses leadership authority")
end)

test("unknown readback cannot claim that owned FFA is currently active", function()
    for _, value in ipairs({"missing", "secret", "error"}) do
        local c = fixture(); c.enable(true, false); c.advance(4)
        c.env.C_PartyInfo.GetLootMethod = function()
            if value == "secret" then return {secret = true} end
            if value == "error" then error("loot readback unavailable") end
            return nil
        end
        c.advance(3)
        expect(not contains(c.loot.status(), "FFA active") and #c.calls == 1,
            "unavailable readback is presented as uncertainty: " .. value)
        c.state.bn = false; c.advance(3)
        expect(#c.calls == 1, "unknown current method cannot authorize restoration: " .. value)
    end
end)

test("unchanged old-method events during an accepted asynchronous request are not manual changes", function()
    local c = fixture(); c.enable(true, false)
    c.env.C_PartyInfo.SetLootMethod = function(method, master)
        c.calls[#c.calls + 1] = {method = method, master = master, time = c.state.time}
        return true -- accepted, with actual state readback arriving later
    end
    c.advance(2.5)
    expect(#c.calls == 1 and c.db.autoLoot.hold == "pending", "request awaits server confirmation")
    c.loot.event("PARTY_LOOT_METHOD_CHANGED") -- getter still reports unchanged Group Loot
    c.advance(0.5)
    expect(c.db.autoLoot.hold == "pending", "unchanged baseline notification must not fabricate manual intervention")
    c.state.method = 0; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(0.5)
    expect(c.db.autoLoot.hold == "owned", "accepted FFA response establishes ownership after observation")
    c.enable(false, false); c.advance(0.5)
    expect(#c.calls == 2 and c.db.autoLoot.hold == "pending", "restoration also waits for readback")
    c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(0.5) -- still FFA until restore is observed
    expect(c.db.autoLoot.hold == "pending", "unchanged source-method notification does not interrupt restoration")
    c.state.method = 3; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(1)
    expect(#c.calls == 2 and not c.db.autoLoot.hold, "asynchronous restore completes without extra writes")
end)

test("an intervening manual method during a pending request permanently revokes that request", function()
    for _, manualMethod in ipairs({1, 3}) do
        local c = fixture(); c.enable(true, false)
        c.env.C_PartyInfo.SetLootMethod = function(method)
            c.calls[#c.calls + 1] = {method = method, time = c.state.time}; return true
        end
        c.advance(2.5)
        if manualMethod == 3 then
            c.state.method = 0; c.loot.event("PARTY_LOOT_METHOD_CHANGED")
        end
        c.state.method = manualMethod; c.loot.event("PARTY_LOOT_METHOD_CHANGED")
        c.state.method = 0; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(1)
        c.state.bn = false; c.advance(5)
        expect(#c.calls == 1 and c.db.autoLoot.hold == "manual",
            "later target readback cannot revive a manually interrupted request: " .. manualMethod)
    end
end)

test("reload preserves only recovery pause, never a stale restoration command", function()
    local c = fixture(); c.enable(true, false); c.advance(4)
    expect(c.db.autoLoot.hold == "owned", "confirmed write records ownership marker")
    local reload = fixture(c.db); reload.state.method = 0; reload.state.bn = false; reload.advance(10)
    expect(#reload.calls == 0 and reload.db.autoLoot.hold == "interrupted", "reload does not replay previous loot mutation")
    for key in pairs(reload.db.autoLoot) do expect(key == "hold", "saved recovery state contains no restoration command or roster identifiers") end
    reload.enable(false, false); reload.advance(3)
    expect(#reload.calls == 0 and reload.state.method == 0, "disabling after reload cannot restore unowned FFA")
end)

test("leaving the old home party clears its manual pause without writing into a new party", function()
    local c = fixture(); c.enable(true, false); c.advance(4)
    c.state.method = 1; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(1)
    c.state.home = false; c.loot.event("GROUP_LEFT", 1); c.advance(2)
    expect(#c.calls == 1 and not c.db.autoLoot.hold, "leaving clears old party state without a restore")
    c.state.home = true; c.state.method = 3
    c.loot.event("GROUP_JOINED", 1, "Party-NEW"); c.advance(4)
    expect(#c.calls == 2 and c.state.method == 0, "new party independently qualifies after stable trust")
end)

test("dungeons use Group Loot with FFA disabled, untrusted members, or manual FFA", function()
    for _, enabled in ipairs({false, true}) do
        for _, method in ipairs({0, 1, 2, 4}) do
            local c = fixture(); c.state.method = method; c.state.friends = {}; c.state.bn = false
            c.enable(enabled, enabled); dungeon(c, true); c.advance(8)
            expect(#c.calls == 1 and c.calls[1].method == 3 and c.state.method == 3,
                "dungeon Group Loot does not depend on outdoor options, trust, or prior method")
            c.advance(20); expect(#c.calls == 1, "confirmed dungeon method stays stable")
        end
    end
    local c = fixture(); extra(c, 2, "Carla", false); extra(c, 3, "Dain", false); extra(c, 4, "Elya", false)
    c.state.method = 0; dungeon(c, true); c.advance(8)
    expect(#c.calls == 1 and c.state.method == 3, "five-person ordinary party gets Group Loot without trust")
    c = fixture(); dungeon(c, true); c.advance(30)
    expect(#c.calls == 0 and c.state.method == 3, "already-active Group Loot needs no write")
    c.state.method = 0; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(8)
    expect(#c.calls == 1 and c.state.method == 3, "a later manual FFA choice cannot override dungeon Group Loot")
    c = fixture(); c.state.method = 0; c.state.members.party1.guid = nil
    c.state.members.party1.name = nil; c.env.C_BattleNet = nil; dungeon(c, true); c.advance(8)
    expect(#c.calls == 1 and c.state.method == 3, "dungeon Group Loot needs party authority, not friend identities")
end)

test("dungeon policy still requires ordinary-party leadership and two-to-five players", function()
    local variants = {
        function(c) c.state.leader = false end, function(c) c.state.leader = nil end,
        function(c) c.state.count = 0 end, function(c) c.state.count = 5 end,
        function(c) c.state.raid = true end, function(c) c.state.instance = true end,
        function(c) c.state.home = false end, function(c) c.env.GetNumSubgroupMembers = nil end,
        function(c) c.env.UnitIsGroupLeader = nil end,
    }
    for index, alter in ipairs(variants) do
        local c = fixture(); c.state.method = 0; dungeon(c, true); alter(c); c.advance(12)
        expect(#c.calls == 0, "dungeon priority cannot bypass party authority: " .. index)
    end
end)

test("unknown or non-dungeon instance context never authorizes outdoor FFA", function()
    local variants = {
        function(c) c.env.IsInInstance = nil end,
        function(c) c.env.IsInInstance = function() error("instance state unavailable") end end,
        function(c) c.env.IsInInstance = function() return nil, "none" end end,
        function(c) c.env.IsInInstance = function() return {secret = true}, "none" end end,
        function(c) c.env.IsInInstance = function() return false, {secret = true} end end,
        function(c) c.env.IsInInstance = function() return false, nil end end,
        function(c) c.env.IsInInstance = function() return false, "party" end end,
        function(c) c.env.IsInInstance = function() return true, "raid" end end,
        function(c) c.env.IsInInstance = function() return true, "pvp" end end,
        function(c) c.env.IsInInstance = function() return true, "arena" end end,
        function(c) c.env.IsInInstance = function() return true, "unknown" end end,
    }
    for index, alter in ipairs(variants) do
        local c = fixture(); c.enable(true, false); alter(c); c.advance(15)
        expect(#c.calls == 0, "uncertain or different instance type cannot be treated as outdoors: " .. index)
    end
end)

test("dungeon Group Loot waits for combat, looting, and restrictions to clear", function()
    local variants = {
        {function(c) c.state.combat = true end, function(c) c.state.combat = false end},
        {function(c) c.state.loot = 1 end, function(c) c.state.loot = 0 end},
        {function(c)
            c.env.Enum.AddOnRestrictionType = {Combat = 1, Encounter = 2, ChallengeMode = 3, PvPMatch = 4, Map = 5}
            c.env.C_RestrictedActions = {GetAddOnRestrictionState = function() return 0 end}
            c.loot.event("ADDON_RESTRICTION_STATE_CHANGED", 1, 1)
        end, function(c) c.loot.event("ADDON_RESTRICTION_STATE_CHANGED", 1, 0) end},
        {function(c) c.env.C_RestrictedActions = {GetAddOnRestrictionState = function() return nil end} end,
            function(c) c.env.C_RestrictedActions = nil end},
    }
    for index, pair in ipairs(variants) do
        local c = fixture(); c.state.method = 0; dungeon(c, true); pair[1](c); c.advance(8)
        expect(#c.calls == 0, "dungeon writes must defer while unsafe: " .. index)
        pair[2](c); c.advance(8)
        expect(#c.calls == 1 and c.state.method == 3, "safe dungeon state allows a single request: " .. index)
    end
    local c = fixture(); c.state.method = 0; c.state.members.party1.combat = true
    dungeon(c, true); c.advance(8)
    expect(#c.calls == 1 and c.state.method == 3,
        "remote-only combat does not postpone Group Loot when local game restrictions permit it")
end)

test("dungeon requests require confirmation and never spam after rejection or timeout", function()
    for _, failure in ipairs({"reject", "throwSetter", "unconfirmed"}) do
        local c = fixture(); c.state.method = 0; dungeon(c, true)
        if failure == "unconfirmed" then
            c.env.C_PartyInfo.SetLootMethod = function(method)
                c.calls[#c.calls + 1] = {method = method, time = c.state.time}; return true
            end
        else c.state[failure] = true end
        c.advance(30)
        expect(#c.calls == 1 and c.calls[1].method == 3 and c.state.method == 0,
            "failed Group Loot gets one request: " .. failure)
        local status = c.loot.status():lower()
        expect(contains(status, "manually") or contains(status, "failed") or contains(status, "not confirmed"),
            "failure stays visible instead of claiming Group Loot is active: " .. failure)
        for _ = 1, 3 do c.loot.event("GROUP_ROSTER_UPDATE"); c.loot.event("PLAYER_ENTERING_WORLD"); c.advance(5) end
        expect(#c.calls == 1, "routine events cannot retry unchanged dungeon failure: " .. failure)
        local instance = c.env.IsInInstance
        c.env.IsInInstance = nil; c.advance(2)
        c.env.IsInInstance = instance; c.advance(8)
        expect(#c.calls == 1, "temporary missing instance data cannot clear a failed dungeon request: " .. failure)
    end
end)

test("missing dungeon loot APIs and unreadable current methods remain read-only", function()
    local variants = {
        function(c) c.env.C_PartyInfo.SetLootMethod = nil end,
        function(c) c.env.C_PartyInfo.IsLootMethodAvailable = function() return false end end,
        function(c) c.env.C_PartyInfo.GetLootMethod = function() return nil end end,
        function(c) c.env.C_PartyInfo.GetLootMethod = function() return {secret = true} end end,
        function(c) c.env.Enum.LootMethod.Group = nil end,
    }
    for index, alter in ipairs(variants) do
        local c = fixture(); c.state.method = 0; dungeon(c, true); alter(c); c.advance(15)
        expect(#c.calls == 0 and c.state.method == 0, "unavailable Group Loot evidence prevents guessing: " .. index)
    end
end)

test("confirmed dungeon Group Loot replaces the old outdoor restoration baseline", function()
    local c = fixture(); c.state.method = 1; c.enable(true, false); c.advance(4)
    expect(c.state.method == 0, "fixture starts with addon-owned outdoor FFA")
    dungeon(c, true); c.advance(8)
    expect(c.state.method == 3 and #c.calls == 2, "dungeon overrides FFA with Group Loot")
    dungeon(c, false); c.advance(2)
    expect(#c.calls == 2, "leaving must begin a new outdoor stability interval")
    c.advance(3)
    expect(c.state.method == 0 and #c.calls == 3, "enabled outdoor policy may resume after stable trust")
    c.enable(false, false); c.advance(3)
    expect(c.state.method == 3 and #c.calls == 4 and c.calls[4].method == 3,
        "outdoor FFA restores the confirmed Group baseline, never the pre-dungeon method")
end)

test("dungeon override preserves an existing manual or interrupted outdoor pause", function()
    for _, hold in ipairs({"manual", "interrupted"}) do
        local c = fixture({settings = {ffaFriends = true}, autoLoot = {hold = hold}})
        c.state.method = 0; dungeon(c, true); c.advance(8)
        expect(#c.calls == 1 and c.state.method == 3, "dungeon policy has priority over an outdoor pause")
        dungeon(c, false); c.advance(15)
        expect(#c.calls == 1 and c.state.method == 3 and c.db.autoLoot.hold == hold,
            "leaving dungeon must retain the original outdoor pause: " .. hold)
    end
end)

test("entering a dungeon supersedes an in-flight FFA request without restoring its old baseline", function()
    local c = fixture(); c.state.method = 1; c.enable(true, false)
    local setter = c.env.C_PartyInfo.SetLootMethod
    c.env.C_PartyInfo.SetLootMethod = function(method, ...)
        if method ~= 0 then return setter(method, ...) end
        c.calls[#c.calls + 1] = {method = method, time = c.state.time}; return true
    end
    c.advance(2.5); expect(#c.calls == 1 and c.db.autoLoot.hold == "pending", "FFA request is still in flight")
    dungeon(c, true); c.advance(0.5)
    c.state.method = 0; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(10)
    expect(c.state.method == 3, "late outdoor FFA readback cannot remain active inside the dungeon")
    local ffa = 0
    for _, call in ipairs(c.calls) do
        if call.method == 0 then ffa = ffa + 1 end
        expect(call.method ~= 1, "dungeon entry must not restore the superseded old baseline")
    end
    expect(ffa == 1, "no new FFA requests are issued inside the dungeon")
end)

test("entering during a pending restore cannot finish on the superseded outdoor method", function()
    local c = fixture(); c.state.method = 1; c.enable(true, false); c.advance(4)
    local setter = c.env.C_PartyInfo.SetLootMethod
    c.env.C_PartyInfo.SetLootMethod = function(method, ...)
        if method ~= 1 then return setter(method, ...) end
        c.calls[#c.calls + 1] = {method = method, time = c.state.time}; return true
    end
    c.state.friends = {}; c.advance(0.5)
    expect(#c.calls == 2 and c.calls[2].method == 1 and c.state.method == 0, "old restoration is in flight")
    dungeon(c, true); c.advance(0.5)
    c.state.method = 1; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(10)
    expect(c.state.method == 3, "late restore readback must yield to dungeon Group Loot")
    local restores = 0
    for _, call in ipairs(c.calls) do if call.method == 1 then restores = restores + 1 end end
    expect(restores == 1, "dungeon policy never reissues the obsolete restoration")
end)

test("leaving with Group Loot unconfirmed cannot issue overlapping outdoor FFA", function()
    local c = fixture(); c.state.method = 0; c.enable(true, false); dungeon(c, true)
    local setter = c.env.C_PartyInfo.SetLootMethod
    c.env.C_PartyInfo.SetLootMethod = function(method, ...)
        if method ~= 3 then return setter(method, ...) end
        c.calls[#c.calls + 1] = {method = method, time = c.state.time}; return true
    end
    c.advance(3); expect(#c.calls == 1 and c.calls[1].method == 3, "Group Loot is awaiting readback")
    dungeon(c, false); c.advance(1)
    expect(#c.calls == 1, "leaving does not send FFA while Group Loot is unresolved")
    c.state.method = 3; c.loot.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(5)
    expect(#c.calls == 2 and c.calls[2].method == 0 and c.state.method == 0,
        "observed Group Loot permits a fresh outdoor FFA request after stabilization")
end)

test("reload and leadership changes cannot replay stale outdoor commands inside a dungeon", function()
    local original = fixture(); original.enable(true, false); original.advance(4)
    local c = fixture(original.db); c.state.method = 0; dungeon(c, true); c.advance(8)
    expect(#c.calls == 1 and c.calls[1].method == 3, "reloaded dungeon derives a fresh Group request from live state")
    dungeon(c, false); c.advance(10)
    expect(#c.calls == 1 and c.db.autoLoot.hold == "interrupted", "reload recovery hold remains paused outdoors")
    c = fixture(); c.state.method = 0; dungeon(c, true)
    c.env.C_PartyInfo.SetLootMethod = function(method)
        c.calls[#c.calls + 1] = {method = method, time = c.state.time}; return true
    end
    c.advance(3); expect(#c.calls == 1, "fixture has one pending Group request")
    c.state.leader = false; c.loot.event("PARTY_LEADER_CHANGED"); c.advance(12)
    expect(#c.calls == 1 and c.state.method == 0, "former leader does not retry or restore loot")
    c.state.leader = true; c.loot.event("PARTY_LEADER_CHANGED"); c.advance(8)
    expect(#c.calls <= 2, "new current leadership may reassess once, never replay the old loop")
end)

print("Loot policy simulations passed: " .. passed .. " scenarios, " .. checks .. " checks.")
