-- Public loot APIs shared by policy and real-TOC simulations. Not a game client.
return function(compareNames)
    local state = {time = 0, method = 3, master = 0, count = 1, leader = true, home = true,
        instance = false, inInstance = false, instanceType = "none", raid = false, combat = false, loot = 0, bn = true,
        members = {player = {guid = "Player-1-SELF", name = "Alice", realm = "Realm", connected = true},
            party1 = {guid = "Player-1-BOB", name = "Bob", realm = "Realm", connected = true}},
        friends = {["Player-1-BOB"] = true}}
    local world = {state = state, calls = {}, lookups = {}, notices = {}}
    function world.install(env)
        if not env.GetTime then env.GetTime = function() return state.time end end
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
        env.strcmputf8i = compareNames
        env.UnitIsConnected = function(unit) return state.members[unit] and state.members[unit].connected end
        env.UnitIsGroupLeader = function(unit)
            if unit == "player" then return state.leader end
            return unit == "party1" and state.leader == false
        end
        env.UnitAffectingCombat = function(unit) return state.members[unit] and state.members[unit].combat or false end
        env.InCombatLockdown = function() return state.combat end
        env.GetNumLootItems = function() return state.loot end
        env.C_PartyInfo = {
            GetLootMethod = function() return state.method, state.master, 0 end,
            IsLootMethodAvailable = function() return true end,
            SetLootMethod = function(method, master)
                world.calls[#world.calls + 1] = {method = method, master = master, time = env.GetTime()}
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
                    if world.changed then world.changed() end
                end
                return not state.reject
            end,
        }
        env.BNConnected = function() return state.bn end
        env.C_BattleNet = {
            IsBattleNetFriendsListSupported = function() return true end,
            IsBattleNetFriendsListEnabled = function() return true end,
            GetAccountInfoByGUID = function(guid)
                world.lookups[#world.lookups + 1] = guid
                return {isFriend = state.friends[guid], bnetAccountID = 123,
                    gameAccountInfo = {playerGuid = "Player-1-OTHERALT"}}
            end,
        }
        env.DEFAULT_CHAT_FRAME = {AddMessage = function(_, message) world.notices[#world.notices + 1] = message end}
    end
    return world
end
