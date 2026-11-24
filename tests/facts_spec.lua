local NS = {}
assert(loadfile("ZKIRPartyQuesting/Rules.lua"))("ZKIR", NS)
assert(loadfile("ZKIRPartyQuesting/Facts.lua"))("ZKIR", NS)
local function snapshot()
    return {level = 60, faction = "Alliance", space = true, quests = {
        [7046] = {active = false, rewarded = false}, [7044] = {active = false, rewarded = true}}}
end
local count = 0
local function check(state, s, name, rule)
    local got = NS.Evaluate(rule or NS.Rules.a7046, s)
    assert(got.state == state, name .. ": " .. got.state .. " / " .. got.reason)
    count = count + 1
    return got
end
check("R", snapshot(), "first acceptance does not require holding target")
local s = snapshot(); s.quests[7044] = {active = true, complete = true, rewarded = false}
check("N", s, "objective complete is not a hand-in")
s.quests[7044].rewarded = nil
check("N", s, "active unrewarded prerequisite is a verified blocker even with missing history")
s = snapshot(); s.quests[7044].rewarded = nil
check("U", s, "missing history")
s = snapshot(); s.quests[7046].active = true
check("U", s, "already active target cannot prove a new start")
s = snapshot(); s.space = false
check("N", s, "log full")
s.space = nil
check("U", s, "missing capacity")
s = snapshot(); s.level = 40
check("N", s, "known level requirement")
s = snapshot(); s.quests[7046] = {active = true, failed = true, rewarded = false}
check("N", s, "failed quest")
local a = check("R", snapshot(), "stable preparation")
s = snapshot(); s.quests[999] = {complete = true}
local b = check("R", s, "unrelated update")
assert(a.signature == b.signature, "unrelated objectives must not change confirmation signature")
s = {quests = {[4201] = {active = false, rewarded = false, complete = false}}}
check("U", s, "turn-in witnesses are not invented blockers", NS.Rules.t4201)
s = {quests = {[2078] = {active = false, rewarded = false, complete = false}, [2098] = {rewarded = true}}}
check("N", s, "dialogue requires its active quest", NS.Rules.g2078)
s.quests[2078].active = true
check("U", s, "robot and key evidence remain missing", NS.Rules.g2078)
local ame = assert(NS.Rules.a4245, "A-Me escort must be in the shipped catalogue")
s = {level = 48, faction = "Alliance", space = true, quests = {
    [4245] = {active = false, rewarded = false}, [4244] = {rewarded = true}}}
check("R", s, "A-Me repair handed in; no casing or accepted escort required", ame)
s.faction = "Horde"
check("R", s, "A-Me also available to Horde", ame)
s.level = 47
check("N", s, "A-Me minimum level is 48", ame)
s.level = 48; s.quests[4244] = {active = true, complete = true, rewarded = false}
check("N", s, "A-Me casing objective complete but repair not handed in", ame)
s.quests[4244] = {}
check("U", s, "A-Me missing repair history remains unknown", ame)
s.quests[4244] = {rewarded = true}; s.quests[4245] = {active = true, failed = false, rewarded = false}
check("U", s, "already-running A-Me escort cannot prove a new start", ame)
for _, rule in pairs(NS.Rules) do
    assert(#("ZKIR: " .. rule.warning) <= 255 and #("ZKIR: " .. rule.nextAction) <= 255)
    assert(rule.warning:find("WAIT"), "every warning must explicitly say wait")
end
print("facts: " .. count .. " preparation cases + catalogue message checks")
