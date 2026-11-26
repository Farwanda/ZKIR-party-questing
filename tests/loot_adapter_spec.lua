-- Real TOC, settings controls and WoW event/update driver with simulated loot APIs.
local client = assert(loadfile("tests/client.lua"))()
local lootWorld = assert(loadfile("tests/loot_world.lua"))()
local passed, checks = 0, 0
local function expect(value, message) checks = checks + 1; assert(value, message) end
local function test(name, fn)
    local ok, err = pcall(fn)
    assert(ok, name .. ": " .. tostring(err))
    passed = passed + 1
end
local function fixture()
    local world = lootWorld()
    local c = client({install = world.install})
    world.changed = function() c.event("PARTY_LOOT_METHOD_CHANGED") end
    c.env.SlashCmdList.ZKIRPARTYQUESTING("settings")
    local control = c.env.ZKIRPartyQuestingFFAFriendsCheckbox
    expect(control and type(control.scripts.OnClick) == "function", "real settings exposes the friend policy control")
    local function toggle(value)
        control:SetChecked(value)
        control.scripts.OnClick(control)
    end
    return c, world.state, world.calls, toggle, world
end

test("settings checkbox activates and restores through the actual update driver", function()
    local c, state, calls, toggle, world = fixture()
    expect(c.ns.Settings.values.ffaFriends == false, "friend automation starts disabled")
    toggle(true)
    expect(c.env.ZKIRPartyQuestingDB.settings.ffaFriends == true and #calls == 0,
        "checkbox persists preference without directly changing loot")
    c.advance(2); expect(#calls == 0, "real update loop respects stable-party delay")
    c.advance(2)
    expect(#calls == 1 and calls[1].method == 0 and c.env.ZKIRPartyQuestingDB.autoLoot.hold == "owned",
        "accepted FFA and its event readback establish ownership")
    c.advance(5); expect(#calls == 1, "periodic updates do not repeat FFA")
    toggle(false); expect(#calls == 1, "disabling schedules restoration through the update loop")
    c.advance(2)
    expect(#calls == 2 and calls[2].method == 3 and state.method == 3 and not c.env.ZKIRPartyQuestingDB.autoLoot.hold,
        "disabling restores and verifies the captured method")
    expect(#world.lookups > 0, "real adapter checks friendship")
    for _, guid in ipairs(world.lookups) do
        assert(guid == "Player-1-BOB", "adapter friend query uses the other member's exact GUID")
    end
    expect(#c.messages == 0, "loot automation sends neither party chat nor addon messages")
end)

test("saved preferences initialize against loot APIs before the first update", function()
    local world = lootWorld()
    local db = {settings = {ffaFriends = true}}
    local c = client({db = db, install = world.install})
    world.changed = function() c.event("PARTY_LOOT_METHOD_CHANGED") end
    expect(c.ns.Settings.values.ffaFriends == true and #world.calls == 0,
        "login loads the enabled preference without directly setting loot")
    c.advance(4)
    expect(#world.calls == 1 and world.state.method == 0 and db.autoLoot.hold == "owned",
        "the first update can evaluate the complete startup party and confirm FFA")
    c = client({db = db, install = world.install})
    c.advance(8)
    expect(#world.calls == 1 and db.autoLoot.hold == "interrupted",
        "reload sees existing FFA but cannot recover the previous client's ownership")
end)

test("leadership transfer events revoke ownership even when leadership returns between updates", function()
    local c, state, calls, toggle = fixture()
    toggle(true); c.advance(4)
    expect(#calls == 1 and c.env.ZKIRPartyQuestingDB.autoLoot.hold == "owned", "fixture begins with owned FFA")
    state.leader = false; c.event("PARTY_LEADER_CHANGED")
    state.leader = true; c.event("PARTY_LEADER_CHANGED")
    state.friends["Player-1-BOB"] = false; c.advance(5)
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

test("world entry applies dungeon Group Loot independently of outdoor FFA settings", function()
    local c, state, calls, toggle = fixture()
    state.method, state.friends["Player-1-BOB"], state.inInstance, state.instanceType = 0, false, true, "party"
    c.event("PLAYER_ENTERING_WORLD"); c.advance(6)
    expect(#calls == 1 and calls[1].method == 3 and state.method == 3,
        "entering a dungeon replaces manual FFA even with both options off and an untrusted member")
    expect(c.ns.Settings.values.ffaFriends == false and c.ns.Settings.values.ffaCharacters == false,
        "dungeon behavior cannot opt into an outdoor FFA policy")
    toggle(true); state.friends["Player-1-BOB"] = true; c.advance(5)
    expect(#calls == 1 and state.method == 3, "enabled outdoor FFA cannot run inside the dungeon")
    state.inInstance, state.instanceType = false, "none"
    c.event("PLAYER_ENTERING_WORLD"); c.advance(2)
    expect(#calls == 1, "world exit starts a fresh stability interval")
    c.advance(3)
    expect(#calls == 2 and calls[2].method == 0 and state.method == 0, "trusted outdoor party resumes FFA after stabilization")
    toggle(false); c.advance(2)
    expect(#calls == 3 and calls[3].method == 3, "outside restoration uses the confirmed dungeon Group baseline")
    expect(#c.messages == 0, "dungeon loot policy sends no party or addon messages")
end)

print("Loot adapter simulations passed: " .. passed .. " scenarios, " .. checks .. " checks.")
