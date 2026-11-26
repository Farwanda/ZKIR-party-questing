local NS = {}
assert(loadfile("ZKIRPartyQuesting/Messages.lua"))("ZKIR", NS)
assert(loadfile("ZKIRPartyQuesting/Rules.lua"))("ZKIR", NS)
assert(loadfile("ZKIRPartyQuesting/Facts.lua"))("ZKIR", NS)
-- Keep previously supported interactions when reorganizing the catalogue.
local supported = [[
a155 a219 a309 g434 a435 a648 a660 a665 a667 a731 a836 a863 a898 a938 a945 a976 a994 a995 a1144
a1222 a1249 a1270 a1273 a1324 a1393 a1440 a1560 a2742 a2767 a2845 a2904 a3367 a3382 a3525 a3982
a4121 a4245 a4261 a4322 a4491 a4770 a4901 a4904 a4966 a5203 a5321 a5713 a5821 a5943 a5944 a6132
a6403 a6482 a6523 a6544 a6641 a7046 g2078 t4201 a452 a87491 a88857 a93125 a93585 a94556 a94927
a94969 a96204 a96811 a97331 a98430 a99053 a99123 a99144
]]
for key in supported:gmatch("%S+") do
    assert(NS.Rules[key], "missing previously supported interaction " .. key)
end
local function prepared(rule)
    local s = {level = 60, space = true, faction = rule.faction == "Both" and "Alliance" or rule.faction,
        classID = rule.classID or 1, raceID = rule.raceIDs and rule.raceIDs[1] or 1, quests = {}}
    if rule.questID then s.quests[rule.questID] = {active = rule.finishTogether == true,
        rewarded = false, complete = rule.finishTogether == true, failed = false} end
    for _, id in ipairs(rule.prerequisites) do s.quests[id] = {rewarded = true, active = false} end
    for _, id in ipairs(rule.exclusive or {}) do s.quests[id] = {rewarded = false, active = false} end
    return s
end
local count, automatic, cases = 0, 0, 0
local function check(rule, s, state, reason)
    local f = NS.Evaluate(rule, s)
    assert(f.state == state, rule.id .. ": " .. f.reason .. " expected " .. state)
    if reason then assert(f.reason == reason, f.reason) end
    cases = cases + 1
    return f
end
for key, rule in pairs(NS.Rules) do
    count = count + 1
    assert(key == rule.id and rule.warning:find("WAIT", 1, true))
    assert(#("ZKIR: " .. rule.warning .. " Leader: /p ZKIR 2147483646 ready Name") <= 255, key .. " fallback chat too long")
    assert(#("ZKIR: " .. rule.nextAction) <= 255)
    if rule.automatic then
        automatic = automatic + 1
        local s = prepared(rule)
        check(rule, s, "R")
        if rule.kind == "accept" then
            assert(rule.partyAccept == true and not rule.participantRoles)
            for _, id in ipairs(rule.prerequisites) do
                s.quests[id] = {active = true, complete = true, rewarded = false}
                check(rule, s, "N")
                s.quests[id] = {rewarded = true, active = false}
            end
            s.space = false; check(rule, s, "N", "LOG_FULL")
        else
            assert(rule.kind == "turnin" and rule.finishTogether)
            s.quests[rule.questID].complete = false
            check(rule, s, "N", "OBJECTIVES_INCOMPLETE")
        end
    else
        local s = prepared(rule)
        if rule.kind == "gossip" and rule.questID then s.quests[rule.questID].active = true end
        check(rule, s, "U")
    end
    if rule.kind == "accept" and not rule.partyAccept then
        assert(not rule.nextAction:find("accept if invited", 1, true), key)
    end
end
-- Corrections that cannot be recovered by scanning quest titles alone.
assert(NS.Rules.a665.prerequisites[1] == 663)
assert(NS.Rules.a4322.prerequisites[1] == 4282 and NS.Rules.a3525.prerequisites[1] == 3523)
assert(NS.Rules.a5203.prerequisites[1] == 5202 and NS.Rules.a4491.prerequisites[1] == 4492)
assert(NS.Rules.a91696.prerequisites[1] == 91698 and NS.Rules.a91696.npcID == 244425)
assert(not NS.Rules.a434 and NS.Rules.g434.npcID == 7766)
assert(NS.Rules.a99053.faction == "Alliance" and not NS.Rules.a99053.raceIDs)
assert(not NS.Rules.a97331.faction, "upstream assumed race mask is not verified access")
for _, id in ipairs({349, 4021, 95056, 9212, 25476, 10425, 8736}) do
    assert(not NS.Rules["a" .. id], "unverified or out-of-scope trigger must not be invented")
end
for _, id in ipairs({994, 995, 6403}) do
    local rule = NS.Rules["a" .. id]; local s = prepared(rule)
    local other = rule.exclusive[1]
    s.quests[other].active = true; check(rule, s, "N", "EXCLUSIVE_" .. other)
    s.quests[other] = {}; check(rule, s, "U")
    s.quests[other] = {active = false, rewarded = false}
    local before = check(rule, s, "R")
    s.quests[999] = {active = true}; local after = check(rule, s, "R")
    assert(before.signature == after.signature)
end
local rule = NS.Rules.a3382; local s = prepared(rule)
s.quests[3382].rewarded = true; check(rule, s, "U") -- repeatable; no permanent blocker
rule = NS.Rules.a3982; s = prepared(rule)
s.quests[3982].rewarded = true; check(rule, s, "N", "ALREADY_REWARDED") -- Forever correction
for _, id in ipairs({1651, 7622, 96204}) do
    rule = NS.Rules["a" .. id]; s = prepared(rule)
    s.classID, s.raceID, s.level = 1, 1, 1
    for _, previous in ipairs(rule.prerequisites) do s.quests[previous] = {rewarded = false} end
    check(rule, s, "U") -- unknown helper role; not forced to qualify for actor's class quest
    s.quests[id].active, s.quests[id].failed = true, true
    check(rule, s, "N", "FAILED")
end
rule = NS.Rules.a99144; s = prepared(rule)
check(rule, s, "U"); s.raceID = 6; check(rule, s, "N", "RACE")
s.raceID = nil; check(rule, s, "U")
rule = NS.Rules.a91696; s = prepared(rule)
s.quests[91698] = {active = true, complete = true, rewarded = false}
check(rule, s, "N", "PREREQUISITE_91698")
s.quests[91698] = {active = false, rewarded = true}; check(rule, s, "U")
print("catalogue: " .. count .. " rules (" .. automatic .. " automatic); " .. cases .. " preparation/message checks")
