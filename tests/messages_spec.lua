local NS = {}
assert(loadfile("ZKIRPartyQuesting/Messages.lua"))("ZKIR", NS)
assert(loadfile("ZKIRPartyQuesting/Rules.lua"))("ZKIR", NS)
local M, rules, checks = NS.Messages, NS.Rules, 0
local function check(value, label)
    assert(value, label)
    checks = checks + 1
end
local function contains(value, expected, label)
    check(value:find(expected, 1, true), label)
end

-- Short UI copy and independent chat copy must preserve every known trigger.
local count = 0
for _, rule in pairs(rules) do
    count = count + 1
    local _, words = M.instruction(rule):gsub("%S+", "")
    check(words >= 3 and words <= 6, rule.id .. " main instruction fits one glance")
    check(#M.consequence(rule) <= 65, rule.id .. " consequence stays short")
    contains(M.chatWarning(rule), "WAIT for everyone", rule.id .. " asks the party to wait")
    contains(M.chatWarning(rule), rule.title, rule.id .. " chat identifies its event")
    contains(M.chatNext(rule), rule.title, rule.id .. " next chat identifies its event")
    contains(M.chatNext(rule), "ALL READY", rule.id .. " next chat signals readiness")
    check(#("ZKIR: " .. M.chatWarning(rule) .. " Leader: /p ZKIR 2147483646 ready Name") <= 255,
        rule.id .. " initial chat with fallback fits game limit")
    check(#("ZKIR: " .. M.chatNext(rule)) <= 255, rule.id .. " next chat fits game limit")
    check(not M.chatNext(rule):find("\n", 1, true), rule.id .. " chat is a single line")
    if rule.kind == "accept" and rule.partyAccept then
        contains(M.nextAction(rule), "accept if invited", rule.id .. " never promises an invitation")
    elseif rule.kind == "accept" then
        check(not M.nextAction(rule):find("if invited", 1, true), rule.id .. " does not invent invitation support")
    end
end
check(count == 102, "all existing interactions retain copy")
check(M.instruction(rules.a7046) == "WAIT. DON'T ACCEPT YET.", "acceptance warning is direct")
check(M.instruction(rules.t5525) == "WAIT. DON'T TURN IN YET.", "reward warning names the right action")
check(M.instruction(rules.n9039) == "WAIT. DON'T START YET.", "dialogue warning names the right action")
check(M.reason("PREREQUISITE_7044", rules.a7046) == "Turn in Legends of Maraudon.",
    "Celebras blocker uses its prerequisite title")
check(M.reason("HAND_IN_7044", rules.a7046) == "Turn in Legends of Maraudon.",
    "objective completion still requires a hand-in")
check(M.reason("PREREQUISITE_4244", rules.a4245, function() return "Repair A-Me" end) == "Turn in Repair A-Me.",
    "runtime quest titles replace opaque IDs")
check(M.reason("PREREQUISITE_4244", rules.a4245) == "Turn in quest #4244.",
    "unavailable title never fabricates a quest name")
check(M.reason("LOG_FULL", rules.a7046) == "Quest log full. Free a slot.", "capacity blocker tells player what to do")
check(M.reason("VERIFY_DETAILS", rules.n9039) == "Unknown. Leader: check.", "missing facts stay unknown")
check(M.reason("OFFLINE", rules.a7046) == "Offline.", "disconnection is explicit")
contains(M.consequence(rules.a7046), "long ritual", "Celebras consequence stays specific")
contains(M.details(rules.a7046), "Objectives alone do not count", "details retain hand-in distinction")
contains(M.consequence(rules.t5525), "Finish crafting first", "Knot crafting loss remains visible")
contains(M.consequence(rules.n9039), "training first", "Doom'rel training loss remains visible")
contains(M.consequence(rules.t96335), "Reported:", "Mason uncertainty remains visible")
contains(M.consequence(rules.t4201), "Reported:", "Nagmara uncertainty remains visible")
contains(M.consequence(rules.a4265), "Reported:", "Raschal uncertainty remains visible")
contains(M.consequence(rules.n7604), "May", "Bly's conditional fight remains conditional")
contains(M.consequence(rules.a7622), "may disrupt", "priest event warns against outside help")
contains(M.nextAction(rules.t96335), "Quest holders: turn in together", "Mason requires coordinated hand-ins")
contains(M.nextAction(rules.t96335), "More Valuable Than Gold", "Mason follow-up remains explicit")
check(not M.details(rules.a1651):find("Hand in first", 1, true), "class helpers need no actor prerequisite")
contains(M.details(rules.n9039), "do not need Mining", "training is not forced on helpers")
contains(M.details(rules.t5525), "Only the freeing player", "Knot helpers need no key")
contains(M.details(rules.n246704), "does not prove combat starts", "barrier access is not mislabeled as immediate combat")
print("messages: " .. checks .. " concise copy and preserved safety checks")
