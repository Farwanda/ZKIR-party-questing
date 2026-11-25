local _, NS = ...

-- One factual copy source feeds the panel and standalone PARTY messages.
local Messages = {}
NS.Messages = Messages

local actions = {accept = "accept", turnin = "turn in", gossip = "start"}
local reasons = {
    NO_RESPONSE = "No reply. Leader: check.", WAITING = "Waiting...",
    CONNECTION_UNKNOWN = "Connection unknown.", OFFLINE = "Offline.",
    LOG_FULL = "Quest log full. Free a slot.", LEVEL = "Level too low.",
    FACTION = "Wrong faction for this quest.", CLASS = "Wrong class for this quest.",
    RACE = "Wrong race for this quest.", ALREADY_REWARDED = "Already turned in.",
    ALREADY_ACTIVE = "Already accepted. Leader: check.", ALREADY_COMPLETE = "Objectives already done.",
    OBJECTIVES_INCOMPLETE = "Finish the quest objectives.", NEED_QUEST = "Accept this quest first.",
    FAILED = "Quest failed.", VERIFY_DETAILS = "Unknown. Leader: check.",
    PREPARED = "Quest checks passed.", LEADER_CONFIRMED = "Leader checked.",
}

local function questName(id, rule, resolver)
    local name = resolver and resolver(id)
    return name or (rule.prerequisiteNames or {})[id] or ("quest #" .. id)
end

function Messages.instruction(rule)
    return "WAIT. DON'T " .. string.upper(actions[rule.kind] or "start") .. " YET."
end

function Messages.consequence(rule)
    return rule.consequence
end

function Messages.nextAction(rule)
    if rule.nextStep then return rule.nextStep end
    if rule.kind == "accept" and rule.partyAccept then
        return "One player: accept.\nOthers: accept if invited."
    end
    return "Follow the leader's start plan."
end

function Messages.details(rule)
    local parts = {}
    if rule.details then parts[#parts + 1] = rule.details end
    if #rule.prerequisites > 0 and not rule.participantRoles then
        local names = {}
        for _, id in ipairs(rule.prerequisites) do names[#names + 1] = questName(id, rule) end
        parts[#parts + 1] = "Hand in first: " .. table.concat(names, ", ") .. ". Objectives alone do not count."
    end
    parts[#parts + 1] = "Ready checks preparation. It does not guarantee participation or credit."
    return table.concat(parts, "\n")
end

function Messages.reason(code, rule, resolver)
    local id = code and code:match("^PREREQUISITE_(%d+)$")
    if id then return "Turn in " .. questName(tonumber(id), rule, resolver) .. "." end
    id = code and code:match("^HAND_IN_(%d+)$")
    if id then return "Turn in " .. questName(tonumber(id), rule, resolver) .. "." end
    id = code and code:match("^EXCLUSIVE_(%d+)$")
    if id then return "Conflicting quest: " .. questName(tonumber(id), rule, resolver) .. "." end
    return reasons[code] or "Unknown. Leader: check."
end

function Messages.chatWarning(rule)
    return "WAIT for everyone. Don't " .. (actions[rule.kind] or "start") .. " " .. rule.title ..
        " yet. " .. Messages.consequence(rule)
end

function Messages.chatNext(rule)
    return "ALL READY: " .. rule.title .. ". " .. Messages.nextAction(rule):gsub("\n", " ")
end
