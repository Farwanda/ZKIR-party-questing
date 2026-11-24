local _, NS = ...

-- The adapter supplies tri-state facts: nil is unavailable, never false by default.
-- Ready checks preparation for this action, not server range/layer/script state.
function NS.Evaluate(rule, snapshot)
    if not rule.questID then
        local signature = "npc-event:" .. rule.id
        if rule.afterQuestID then
            local history = (snapshot.quests or {})[rule.afterQuestID] or {}
            -- Actor access can change; helpers still need no personal hand-in.
            signature = signature .. ";reward" .. rule.afterQuestID .. "=" .. tostring(history.rewarded)
        end
        return {state = "U", reason = "VERIFY_DETAILS", signature = signature}
    end
    local parts, blockers, missing = {}, {}, false
    local function value(key, v)
        parts[#parts + 1] = key .. "=" .. tostring(v)
        if v == nil then missing = true end
        return v
    end
    local function block(reason) blockers[#blockers + 1] = reason end
    if rule.participantRoles then
        -- Class-event helpers need not qualify for the actor's quest. Their role
        -- cannot be inferred from class, level, or the absence of prerequisites.
        local target = snapshot.quests[rule.questID] or {}
        local held = value("active", target.active)
        local failed = value("failed", target.failed)
        value("reward", target.rewarded)
        value("complete", target.complete)
        value("class", snapshot.classID); value("race", snapshot.raceID)
        for _, id in ipairs(rule.prerequisites) do
            value("reward" .. id, (snapshot.quests[id] or {}).rewarded)
        end
        return {state = held == true and failed == true and "N" or "U",
            reason = held == true and failed == true and "FAILED" or "VERIFY_DETAILS",
            signature = table.concat(parts, ";")}
    end
    for _, id in ipairs(rule.prerequisites) do
        local q = snapshot.quests[id] or {}
        local done = value("reward" .. id, q.rewarded)
        if done == false then block("PREREQUISITE_" .. id) end
        if q.active == true and done ~= true then block("HAND_IN_" .. id) end
        -- Objective counts are deliberately absent: they cannot prove a hand-in.
    end
    local target = snapshot.quests[rule.questID] or {}
    local rewarded = value("reward", target.rewarded)
    local active = value("active", target.active)
    local failed = active == true and value("failed", target.failed) or false
    if failed == true then block("FAILED") end
    if rule.kind == "accept" then
        if rewarded == true and not rule.repeatable then block("ALREADY_REWARDED") end
        if active == true then missing = true end -- may be a running attempt; never promise joining it
        local capacity = value("space", snapshot.space)
        if capacity == false then block("LOG_FULL") end
        local enough = snapshot.level and rule.minLevel and snapshot.level >= rule.minLevel
        if enough == false and rule.alternativeMinLevel and snapshot.level >= rule.alternativeMinLevel then
            enough = nil -- source disagreement: neither Ready nor a verified level blocker
        end
        local level = value("level", enough)
        if level == false then block("LEVEL") end
        local faction = value("faction", snapshot.faction)
        if not rule.faction then missing = true
        elseif faction and rule.faction ~= "Both" and faction ~= rule.faction then block("FACTION") end
        if rule.classID then
            local class = value("class", snapshot.classID)
            if class and class ~= rule.classID then block("CLASS") end
        end
        if rule.raceIDs then
            local race, allowed = value("race", snapshot.raceID), false
            for _, id in ipairs(rule.raceIDs) do if race == id then allowed = true end end
            if race and not allowed then block("RACE") end
        end
        for _, id in ipairs(rule.exclusive or {}) do
            local q = snapshot.quests[id] or {}
            local held = value("exclusiveActive" .. id, q.active)
            local done = value("exclusiveReward" .. id, q.rewarded)
            if held == true or done == true then block("EXCLUSIVE_" .. id) end
        end
        if rule.partyAccept ~= true then missing = true end
    elseif rule.kind == "gossip" then
        if active == false then block("NEED_QUEST") end
        if value("complete", target.complete) == true then block("ALREADY_COMPLETE") end
        -- Key availability and robot state aren't inferred from a quest-log entry.
        missing = true
    else
        -- Other participants may be witnesses rather than hand-in candidates.
        -- Do not invent a requirement that everyone holds this turn-in quest.
        local complete = value("complete", target.complete)
        if rule.finishTogether and active == true then
            if complete == false then block("OBJECTIVES_INCOMPLETE") end
        else
            missing = true
        end
    end
    local state, reason = "R", "PREPARED"
    if #blockers > 0 then state, reason = "N", blockers[1]
    elseif missing or not rule.automatic then state, reason = "U", "VERIFY_DETAILS" end
    if active and rule.kind == "accept" and state == "U" then reason = "ALREADY_ACTIVE" end
    return {state = state, reason = reason, signature = table.concat(parts, ";")}
end
