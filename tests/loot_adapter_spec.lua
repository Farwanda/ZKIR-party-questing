-- Real TOC, settings controls and WoW event/update driver with simulated loot APIs.
local client = assert(loadfile("tests/client.lua"))()
local passed, checks = 0, 0
local function expect(value, message) checks = checks + 1; assert(value, message) end
local function test(name, fn)
    local ok, err = pcall(fn)
    assert(ok, name .. ": " .. tostring(err))
    passed = passed + 1
end
local function fixture()
    local c = client({party = true})
    local state = {method = 3, leader = true, friend = true}
    local calls = {}
    c.env.Enum = {LootMethod = {Freeforall = 0, Group = 3, Roundrobin = 1,
        Masterlooter = 2, Needbeforegreed = 4, Personal = 5}}
    c.env.IsInGroup = function(category) return category == 1 end
    c.env.UnitGUID = function(unit) return unit == "player" and "Player-1-ALICE" or "Player-1-BOB" end
    c.env.UnitIsGroupLeader = function(unit)
        if unit == "player" then return state.leader end
        return not state.leader
    end
    c.env.UnitAffectingCombat = function() return false end
    c.env.InCombatLockdown = function() return false end
    c.env.GetNumLootItems = function() return 0 end
    c.env.BNConnected = function() return true end
    c.env.C_BattleNet = {GetAccountInfoByGUID = function(guid)
        expect(guid == "Player-1-BOB", "adapter friend query uses the other member's exact GUID")
        return {isFriend = state.friend}
    end}
    c.env.C_PartyInfo = {
        GetLootMethod = function() return state.method, 0, 0 end,
        IsLootMethodAvailable = function() return true end,
        SetLootMethod = function(method)
            calls[#calls + 1] = method
            state.method = method
            c.event("PARTY_LOOT_METHOD_CHANGED")
            return true
        end,
    }
    c.env.SlashCmdList.ZKIRPARTYQUESTING("settings")
    local control = c.env.ZKIRPartyQuestingFFAFriendsCheckbox
    expect(control and type(control.scripts.OnClick) == "function", "real settings exposes the friend policy control")
    local function toggle(value)
        control:SetChecked(value)
        control.scripts.OnClick(control)
    end
    return c, state, calls, toggle
end

test("settings checkbox activates and restores through the actual update driver", function()
    local c, state, calls, toggle = fixture()
    expect(c.ns.Settings.values.ffaFriends == false, "friend automation starts disabled")
    toggle(true)
    expect(c.env.ZKIRPartyQuestingDB.settings.ffaFriends == true and #calls == 0,
        "checkbox persists preference without directly changing loot")
    c.advance(2); expect(#calls == 0, "real update loop respects stable-party delay")
    c.advance(2)
    expect(#calls == 1 and calls[1] == 0 and c.env.ZKIRPartyQuestingDB.autoLoot.hold == "owned",
        "accepted FFA and its event readback establish ownership")
    c.advance(5); expect(#calls == 1, "periodic updates do not repeat FFA")
    toggle(false); expect(#calls == 1, "disabling schedules restoration through the update loop")
    c.advance(2)
    expect(#calls == 2 and calls[2] == 3 and state.method == 3 and not c.env.ZKIRPartyQuestingDB.autoLoot.hold,
        "disabling restores and verifies the captured method")
    expect(#c.messages == 0, "loot automation sends neither party chat nor addon messages")
end)

test("leadership transfer events revoke ownership even when leadership returns between updates", function()
    local c, state, calls, toggle = fixture()
    toggle(true); c.advance(4)
    expect(#calls == 1 and c.env.ZKIRPartyQuestingDB.autoLoot.hold == "owned", "fixture begins with owned FFA")
    state.leader = false; c.event("PARTY_LEADER_CHANGED")
    state.leader = true; c.event("PARTY_LEADER_CHANGED")
    state.friend = false; c.advance(5)
    expect(#calls == 1 and c.env.ZKIRPartyQuestingDB.autoLoot.hold == "interrupted",
        "actual event forwarding preserves brief authority loss and prevents stale restoration")
    state.leader, state.method = false, 1
    c.event("PARTY_LEADER_CHANGED"); c.event("PARTY_LOOT_METHOD_CHANGED"); c.advance(5)
    expect(#calls == 1 and state.method == 1, "former leader never overrides the new leader's method")
    expect(#c.messages == 0, "leadership recovery stays local")
end)

test("nested loot and roster events render coordination once per update", function()
    local c, state, calls, toggle = fixture()
    local setter = c.env.C_PartyInfo.SetLootMethod
    c.env.C_PartyInfo.SetLootMethod = function(...)
        local accepted = setter(...) -- Emits PARTY_LOOT_METHOD_CHANGED inside the update.
        c.event("GROUP_ROSTER_UPDATE") -- The live probe also observed this after loot changes.
        return accepted
    end
    c.event("QUEST_DETAIL"); toggle(true); c.advance(2)
    expect(#calls == 0, "fixture reaches the stable-party delay before applying loot")
    local updates, render = 0, c.ns.UI.update
    c.ns.UI.update = function(...) updates = updates + 1; return render(...) end
    c.advance(0.5)
    expect(#calls == 1 and state.method == 0, "real loot runtime emitted nested events while applying FFA")
    expect(updates == 1, "nested event handlers must defer rendering to the outer update")
    c.advance(0.5)
    expect(c.env.ZKIRPartyQuestingDB.autoLoot.hold == "owned" and not c.ns.engine.active.started,
        "batching preserves loot readback and the unrelated unresolved quest")
end)

print("Loot adapter simulations passed: " .. passed .. " scenarios, " .. checks .. " checks.")
