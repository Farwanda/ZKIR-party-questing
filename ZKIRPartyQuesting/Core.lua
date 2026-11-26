local _, NS = ...

-- Pure state machine. No game APIs, game actions, or wall-clock timers here.
local Core = {}
Core.__index = Core
local DISCOVERY, FRESH, PULSE = 5, 12, 3
local labels = {R = "Ready", N = "Not Ready", U = "Unknown"}

local function split(s)
    local out = {}
    for part in (s .. "|"):gmatch("(.-)|") do out[#out + 1] = part end
    return out
end

function NS.Hash(s)
    local h = 5381
    for i = 1, #s do h = (h * 33 + s:byte(i)) % 2147483647 end
    return tostring(h)
end

local function sortedKeys(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys)
    return keys
end

local function olderBoot(a, b)
    local at, ac = a:match("^(%d+)%.(%d+)$")
    local bt, bc = b:match("^(%d+)%.(%d+)$")
    at, ac = tonumber(at) or 0, tonumber(ac) or tonumber(a) or 0
    bt, bc = tonumber(bt) or 0, tonumber(bc) or tonumber(b) or 0
    return at < bt or (at == bt and ac < bc)
end

function NS.New(config)
    local self = setmetatable({cfg = config, me = config.me, roster = {}, peers = {},
        facts = {}, manual = {}, acknowledgements = {}, lastPulse = -100,
        sequence = 0, serial = 0, factVersion = 0, confirmSequence = 0,
        stableAt = config.now(), healthy = true}, Core)
    self.saved = config.saved or {}
    self.saved.ledger = self.saved.ledger or {}
    self.saved.retired = self.saved.retired or {}
    local a = self.saved.active
    if a and NS.Rules[a.ruleID] and config.wall() - (a.time or 0) < 1800 then
        self.active = a
        self.openedAt = config.now()
        self.restoring = true
    end
    -- Facts and manual decisions never survive a reload.
    return self
end

function Core:changed()
    self.saved.active = self.active
    if self.cfg.changed then self.cfg.changed(self) end
end

function Core:invalidateReadiness()
    self.manual, self.acknowledgements, self.pending = {}, {}, nil
    self.stableAt = self.cfg.now()
end

function Core:cancelReconciliation()
    self.probes = {}
end

function Core:resetReconciliation()
    self:cancelReconciliation()
    self.failedProbes = {}
end

function Core:suspendSync(notice)
    self.healthy, self.notice = false, notice
    self:cancelReconciliation()
    self:invalidateReadiness()
end

function Core:setRoster(list)
    local roster, leader, parts = {}, nil, {}
    for _, m in ipairs(list) do
        roster[m.name] = {name = m.name, connected = m.connected, leader = m.leader == true}
        if m.leader then leader = m.name end
    end
    for _, name in ipairs(sortedKeys(roster)) do
        local m = roster[name]
        local connection = m.connected == true and "+" or m.connected == false and "-" or "?"
        parts[#parts + 1] = name .. connection .. (m.leader and "L" or "M")
    end
    local signature = table.concat(parts, ",")
    if signature ~= self.rosterSignature then
        self:resetReconciliation()
        if self.active and self.active.retiredRoster ~= signature then self.active.retiredRoster = nil end
        self:invalidateReadiness()
        -- A roster that changes away and back must not revive an old signed decision.
        if self.localFact then
            self.factVersion = self.factVersion + 1
            self.localFact.signature = self.factVersion .. "." .. NS.Hash(self.localFact.original)
            if self.facts[self.me] then self.facts[self.me].signature = self.localFact.signature end
        end
        for name in pairs(self.peers) do
            if not roster[name] or not roster[name].connected then
                self.peers[name] = nil
                if not roster[name] or not self.facts[name] or self.facts[name].state ~= "N" then self.facts[name] = nil end
            end
        end
        self.rosterSignature = signature
    end
    self.roster, self.leader, self.count = roster, leader, #list
    self:changed()
end

function Core:send(...)
    if self.count == 1 then return true end
    -- A new attempt may verify recovery once; ordinary traffic stays suspended.
    if not self.healthy and select(1, ...) ~= "V" then return false end
    local parts = {"1", ...}
    for i, part in ipairs(parts) do
        if type(part) ~= "string" or part:find("[|\r\n]") then return false end
    end
    local payload = table.concat(parts, "|")
    if #payload > 255 then return false end
    local ok, sent = pcall(self.cfg.send, payload)
    if not ok or sent ~= true then
        self:suspendSync("WAIT. Party sync failed.")
        return false
    end
    return true
end

function Core:adopt(a)
    if self.active and self.active.key ~= a.key then
        -- Saved retired keys reject replaced attempts; active.started instead
        -- records that preparation ended after an observed action.
        self.saved.retired[self.active.key] = self.cfg.wall()
    end
    self.active = a
    self.restoring = false
    self.facts, self.peers = {}, {}
    self:resetReconciliation()
    self.localFact = nil
    self.openedAt, self.lastPulse = self.cfg.now(), -100
    self.notice = nil
    self.healthy = true
    self:invalidateReadiness()
    self:changed()
end

function Core:startAttempt(ruleID, context)
    self.serial = self.serial + 1
    local key = self.cfg.wall() .. "." .. self.cfg.boot .. "." .. self.serial .. "." .. NS.Hash(self.me)
    self:adopt({key = key, parent = self.active and self.active.key or "0", ruleID = ruleID,
        context = context, time = self.cfg.wall(), started = false})
    self:broadcast()
end

function Core:detect(ruleID, context)
    if not NS.Rules[ruleID] then return end
    context = context or "unknown"
    if self.active and self.active.ruleID == ruleID and self.active.context == context then
        self:changed()
        return
    end
    self:startAttempt(ruleID, context)
end

function Core:retry()
    if not self.active or self.cfg.now() - self.openedAt < DISCOVERY then return false end
    self:startAttempt(self.active.ruleID, self.active.context)
    return true
end

function Core:broadcast()
    local a = self.active
    if not a then return end
    if a.started then
        -- Exact-key retirement reaches existing peers without opening a past
        -- interaction for a new party. Only the original party may reconcile aliases.
        self:send("X", a.key)
        if a.retiredRoster and a.retiredRoster == self.rosterSignature then
            self:send("E", a.key, a.parent, a.ruleID, a.context, tostring(a.time), "1")
        end
        return
    end
    self:send("E", a.key, a.parent, a.ruleID, a.context, tostring(a.time), "0")
    self:send("H", a.key, self.cfg.boot)
    self:publishFact()
    for _, stage in ipairs({"I", "G"}) do
        local slot = a.key .. stage
        if self.saved.ledger[slot] and not (self.saved.claims and self.saved.claims[slot]) then
            self:send("L", a.key, stage)
        end
    end
end

function Core:setFact(fact)
    if not self.active or self.active.started or not labels[fact.state] or type(fact.signature) ~= "string" then return end
    local state, reason = fact.state, fact.reason or "UNKNOWN"
    local previous = self.facts[self.me]
    if previous and previous.state == "N" and state == "U" then state, reason = "N", previous.reason end
    local old = self.localFact
    if not old or old.original ~= fact.signature or old.state ~= state then
        self.factVersion = self.factVersion + 1
        self:invalidateReadiness()
    end
    self.localFact = {state = state, reason = reason,
        signature = self.factVersion .. "." .. NS.Hash(fact.signature)}
    -- Compare the original signature, not its wire hash, on the next update.
    self.localFact.original = fact.signature
    self.facts[self.me] = {state = state, reason = reason,
        signature = self.localFact.signature, boot = self.cfg.boot, at = self.cfg.now()}
    self:changed()
end

function Core:publishFact()
    local f, a = self.localFact, self.active
    if not f or not a or a.started then return end
    self.sequence = self.sequence + 1
    self:send("F", a.key, self.cfg.boot, tostring(self.sequence), f.state, f.reason, f.signature)
end

function Core:fingerprint()
    local parts = {self.active and self.active.key or "", self.rosterSignature or ""}
    for _, name in ipairs(sortedKeys(self.roster)) do
        local f, p = self.facts[name], self.peers[name]
        parts[#parts + 1] = name .. ":" .. (name == self.me and self.cfg.boot or (p and p.boot or "-")) .. ":" ..
            (f and (f.state .. f.signature .. f.boot) or "-")
    end
    return NS.Hash(table.concat(parts, "/"))
end

local function buildRows(self, fingerprint, now)
    local rows = {}
    for _, name in ipairs(sortedKeys(self.roster)) do
        local m, f = self.roster[name], self.facts[name]
        local fresh = f and (name == self.me or now - f.at <= FRESH)
        local row = {name = name, status = "Unknown", source = "none", reason = "NO_RESPONSE"}
        if m.connected == false then
            row.status, row.reason, row.source = "Not Ready", "OFFLINE", "automatic"
        elseif m.connected == nil then
            row.reason = "CONNECTION_UNKNOWN"
        elseif f and f.state == "N" then
            row.status, row.reason, row.source = "Not Ready", f.reason, "automatic"
        elseif self.active and now - self.openedAt < DISCOVERY and not fresh then
            row.status, row.reason = "Waiting", "WAITING"
        elseif fresh then
            row.status, row.reason, row.source = labels[f.state], f.reason, "automatic"
        end
        local manual = self.manual[name]
        if row.status == "Unknown" and (not f or fresh) and manual and manual.fingerprint == fingerprint then
            row.status, row.reason, row.source = labels[manual.state], "LEADER_CONFIRMED", "leader"
        end
        row.allowConfirmation = self.active and not self.active.started and m.connected and (not f or fresh) and
            (row.status == "Unknown" or row.source == "leader") and self.healthy
        row.canConfirm = self.me == self.leader and row.allowConfirmation
        rows[#rows + 1] = row
    end
    return rows
end

local function readyForAction(self, rows, now)
    if not self.active or self.active.started or not self.healthy or self.count == 0 then return false end
    if now - self.stableAt < DISCOVERY then return false end
    for _, row in ipairs(rows) do if row.status ~= "Ready" then return false end end
    return true
end

function Core:presentation()
    local fingerprint, now = self:fingerprint(), self.cfg.now()
    local rows = buildRows(self, fingerprint, now)
    return {rows = rows, fingerprint = fingerprint, ready = readyForAction(self, rows, now)}
end

function Core:rows()
    return self:presentation().rows
end

function Core:allReady()
    return self:presentation().ready
end

function Core:confirm(name, state)
    if not self.active or self.active.started or state ~= "R" and state ~= "N" then return false end
    for _, row in ipairs(self:rows()) do
        if row.name == name and row.canConfirm then
            local fingerprint = self:fingerprint()
            self.confirmSequence = self.confirmSequence + 1
            self.manual[name] = {state = state, fingerprint = fingerprint, revision = self.confirmSequence}
            self:send("M", self.active.key, name, state, fingerprint, tostring(self.confirmSequence))
            self:changed()
            return true
        end
    end
    return false
end

function Core:confirmFromChat(sender, token, name, state, lineID)
    if not self.active or self.active.started or sender ~= self.leader or token ~= self:fingerprint() or
        (state ~= "R" and state ~= "N") or not self.healthy then return false end
    self.chatLines = self.chatLines or {}
    if lineID and self.chatLines[lineID] then return false end
    for _, row in ipairs(self:rows()) do
        if row.name == name and row.allowConfirmation then
            self.confirmSequence = self.confirmSequence + 1
            self.manual[name] = {state = state, fingerprint = token, revision = self.confirmSequence}
            if lineID then self.chatLines[lineID] = true end
            self:changed()
            return true
        end
    end
    return false
end

function Core:chatHelp(sender)
    if sender ~= self.leader or not self.active or self.active.started or self:owner() ~= self.me or not self.healthy or
        self.cfg.now() - (self.lastHelp or -100) < 10 then return end
    self.lastHelp = self.cfg.now()
    pcall(self.cfg.chat, "ZKIR leader: check the player, then /p ZKIR " .. self:fingerprint() ..
        " ready Name-Realm (or notready).")
end

function Core:owner()
    if self.count == 1 then return self.me end
    local names = {}
    for name, m in pairs(self.roster) do
        local p = self.peers[name]
        if m.connected and (name == self.me or (p and self.cfg.now() - p.at <= FRESH)) then
            if name == self.leader then return name end
            names[#names + 1] = name
        end
    end
    table.sort(names)
    return names[1]
end

function Core:retire()
    local a = self.active
    if not a or a.started then return false end
    a.started = true -- Preparation is closed; this is not proof of event credit.
    a.retiredRoster = (self.count or 0) > 1 and self.rosterSignature or nil
    self:cancelReconciliation()
    self:invalidateReadiness()
    return true
end

function Core:action(questID, kind)
    local a = self.active
    if not a or a.started then return end
    local rule = NS.Rules[a.ruleID]
    if rule.questID == questID and rule.kind == kind then
        self:retire()
        self:send("X", a.key)
        self:changed()
    end
end

function Core:probe(sender, candidate, alias)
    -- Different local histories need a live answer, not trust in an old E packet.
    self.probes = self.probes or {}
    self.failedProbes = self.failedProbes or {}
    local failureKey = sender .. ":" .. candidate.key
    if self.failedProbes[failureKey] then return end
    local probe, now = self.probes[sender], self.cfg.now()
    if not probe or probe.event.key ~= candidate.key or now - probe.at > FRESH then
        self.probeSequence = (self.probeSequence or 0) + 1
        probe = {event = candidate, alias = alias, localKey = self.active.key, at = now,
            successor = candidate.parent == self.active.key,
            token = self.cfg.boot .. "." .. self.probeSequence, sentAt = -100}
        self.probes[sender] = probe
    end
    if now - probe.sentAt >= PULSE then
        probe.sentAt = now
        if not self:send("V", candidate.key, probe.token) then self.failedProbes[failureKey] = true end
    end
end

function Core:cancelProbe(key)
    for name, probe in pairs(self.probes or {}) do
        if probe.event.key == key then
            self.probes[name] = nil
            if not probe.alias then self.saved.retired[key] = self.cfg.wall() end
        end
    end
end

local function concurrentAttempt(a, candidate, rosterSignature)
    return a and a.parent == candidate.parent and a.ruleID == candidate.ruleID and a.context == candidate.context and
        -- A completed solo/previous-party event is not this party's concurrent alias.
        (not a.started or a.retiredRoster == rosterSignature)
end

local function shouldAdoptVerified(self, probe)
    local a = self.active
    local needsRecovery = self.restoring or not self.healthy
    local replacesFinished = a.started and not probe.alias
    return probe.successor or replacesFinished or needsRecovery or probe.event.key < a.key
end

function Core:adoptVerified(probe)
    local a, inherited = self.active, {}
    if probe.alias then
        for _, stage in ipairs({"I", "G"}) do inherited[stage] = self.saved.ledger[a.key .. stage] end
    end
    probe.event.started = probe.alias and a.started or false
    probe.event.retiredRoster = probe.event.started and a.retiredRoster or nil
    self:adopt(probe.event)
    for stage, timestamp in pairs(inherited) do self.saved.ledger[probe.event.key .. stage] = timestamp end
end

function Core:receiveReply(sender, p)
    local key, token, started = p[3], p[4], p[5]
    local a, probe = self.active, self.probes and self.probes[sender]
    if #p ~= 5 or (started ~= "0" and started ~= "1") or not a or not probe or
        key ~= probe.event.key or token ~= probe.token or
        probe.localKey ~= a.key or self.cfg.now() - probe.at > FRESH then return end
    self.probes[sender] = nil
    if started == "1" then
        if not probe.alias then return end -- A past action cannot open a different event.
        if self:retire() then self:changed() end
    end
    if shouldAdoptVerified(self, probe) then self:adoptVerified(probe) end
end

function Core:receiveEvent(sender, p)
    local key, parent, ruleID, context, time, started = p[3], p[4], p[5], p[6], tonumber(p[7]), p[8]
    if #p ~= 8 or not NS.Rules[ruleID] or not time or (started ~= "0" and started ~= "1") or #key > 100 or
        self.saved.retired[key] or math.abs(self.cfg.wall() - time) > 1800 then return end
    local a = self.active
    if a and a.key == key then
        self.restoring = false
        if started == "1" and self:retire() then self:changed() end
        return
    end
    -- Server time is only a replay bound, never consensus or election ordering.
    local candidate = {key = key, parent = parent, ruleID = ruleID, context = context, time = time, started = false}
    local concurrent = concurrentAttempt(a, candidate, self.rosterSignature)
    if started == "1" and not concurrent then return end -- Past actions cannot open or replace a warning.
    if not a then
        self:adopt(candidate)
    elseif not concurrent or started == "1" or key < a.key then
        self:probe(sender, candidate, concurrent)
    end
end

function Core:receiveHeartbeat(sender, boot)
    local old = self.peers[sender]
    if not boot:match("^%d+%.?%d*$") or (old and olderBoot(boot, old.boot)) then return end
    self.retiredBoots = self.retiredBoots or {}
    self.retiredBoots[sender] = self.retiredBoots[sender] or {}
    if self.retiredBoots[sender][boot] then return end
    if not old or old.boot ~= boot or old.expired then
        if old and old.boot ~= boot then self.retiredBoots[sender][old.boot] = true end
        self:invalidateReadiness()
        if not self.facts[sender] or self.facts[sender].state ~= "N" then self.facts[sender] = nil end
    end
    self.peers[sender] = {boot = boot, at = self.cfg.now()}
    self:changed()
end

function Core:receiveFact(sender, boot, sequence, state, reason, signature)
    local peer, old = self.peers[sender], self.facts[sender]
    if not peer or peer.boot ~= boot or (old and old.boot == boot and old.seq >= sequence) then return end
    if old and old.state == "N" and state == "U" then state, reason = "N", old.reason end
    if not old or old.signature ~= signature or old.state ~= state then self:invalidateReadiness() end
    self.facts[sender] = {boot = boot, seq = sequence, state = state, reason = reason,
        signature = signature, at = self.cfg.now()}
    self:changed()
end

function Core:receiveConfirmation(sender, name, state, fingerprint, revision)
    if sender ~= self.leader or not self.roster[name] or (state ~= "R" and state ~= "N") or
        fingerprint ~= self:fingerprint() or not revision then return end
    local old = self.manual[name]
    if not old or revision > old.revision then
        self.manual[name] = {state = state, fingerprint = fingerprint, revision = revision}
    end
end

function Core:receiveAnnouncement(sender, kind, stage, fingerprint)
    local a = self.active
    if kind == "L" and (stage == "I" or stage == "G") then
        self.saved.ledger[a.key .. stage] = self.cfg.wall()
        if self.saved.claims then self.saved.claims[a.key .. stage] = nil end
    elseif kind == "Q" and sender == self:owner() and fingerprint == self:fingerprint() and
        (stage == "I" or (stage == "G" and self:allReady())) and self.healthy then
        -- Replicate the at-most-once claim BEFORE the sender attempts party chat.
        local slot = a.key .. stage
        if not self.saved.ledger[slot] or self.saved.claims and self.saved.claims[slot] == sender then
            self.saved.claims = self.saved.claims or {}
            self.saved.claims[slot] = sender
            self.saved.ledger[slot] = self.cfg.wall()
            self:send("K", a.key, stage, fingerprint)
        end
    elseif kind == "K" and self.pending and stage == self.pending.stage and fingerprint == self.pending.fingerprint then
        self.acknowledgements[sender] = true
    end
end

function Core:receive(sender, payload)
    if sender == self.me or not self.roster[sender] or not self.roster[sender].connected or
        type(payload) ~= "string" or #payload > 255 then return end
    local p = split(payload)
    if p[1] ~= "1" then return end
    local kind, a = p[2], self.active
    if kind == "Y" then return self:receiveReply(sender, p) end
    if kind == "X" and #p == 3 then self:cancelProbe(p[3]) end
    if kind == "E" then return self:receiveEvent(sender, p) end
    if not a or p[3] ~= a.key then return end
    if kind == "V" and #p == 4 then
        if not a.started or a.retiredRoster == self.rosterSignature then
            self:send("Y", a.key, p[4], a.started and "1" or "0")
        end
        return
    end
    if a.started and kind ~= "X" and kind ~= "L" then return end
    if kind == "H" and p[4] then
        return self:receiveHeartbeat(sender, p[4])
    elseif kind == "F" and labels[p[6]] and p[7] and p[8] and tonumber(p[5]) then
        return self:receiveFact(sender, p[4], tonumber(p[5]), p[6], p[7], p[8])
    elseif kind == "M" then
        self:receiveConfirmation(sender, p[4], p[5], p[6], tonumber(p[7]))
    elseif kind == "X" then
        self:retire()
    elseif kind == "L" or kind == "Q" or kind == "K" then
        self:receiveAnnouncement(sender, kind, p[4], p[5])
    end
    self:changed()
end

function Core:announce(stage)
    local a, now = self.active, self.cfg.now()
    -- Solo presentation must not consume a PARTY announcement slot before a group forms.
    if not a or a.started or (self.count or 0) < 2 or self:owner() ~= self.me or not self.healthy or now - self.stableAt < DISCOVERY or
        now - self.openedAt < DISCOVERY then return end
    local slot = a.key .. stage
    if self.saved.ledger[slot] then return end
    if not self.pending or self.pending.stage ~= stage or self.pending.fingerprint ~= self:fingerprint() then
        self.pending = {stage = stage, fingerprint = self:fingerprint(), at = now}
        self.acknowledgements = {}
        self:send("Q", a.key, stage, self.pending.fingerprint)
        return
    end
    if now - self.pending.at < 2 then return end
    for name, p in pairs(self.peers) do
        if self.roster[name] and not self.acknowledgements[name] then return end
    end
    self.saved.ledger[slot] = self.cfg.wall()
    if not self:send("L", a.key, stage) then return end
    local rule = NS.Rules[a.ruleID]
    local message = stage == "I" and rule.warning or rule.nextAction
    if stage == "I" and self:owner() ~= self.leader then
        message = message .. " Leader: /p ZKIR " .. self:fingerprint() .. " ready Name"
    end
    if self.count > 1 then
        local ok, sent = pcall(self.cfg.chat, "ZKIR: " .. message)
        if not ok or not sent then self.notice = "WAIT. Party chat failed. Check with the party." end
    end
    self.pending = nil
end

function Core:tick()
    if not self.active then return end
    local now = self.cfg.now()
    if self.active.started then
        if now - self.lastPulse >= PULSE then self.lastPulse = now; self:broadcast() end
        self:changed()
        return
    end
    for name, p in pairs(self.peers) do
        if now - p.at > FRESH and not p.expired then
            p.expired = true
            self:suspendSync("WAIT. An addon stopped responding. Reconnect, then /zkir retry.")
        end
    end
    if now - self.lastPulse >= PULSE then
        self.lastPulse = now
        self:broadcast()
        if self.pending then self:send("Q", self.active.key, self.pending.stage, self.pending.fingerprint) end
        if self.me == self.leader then
            for name, m in pairs(self.manual) do
                self:send("M", self.active.key, name, m.state, m.fingerprint, tostring(m.revision))
            end
        end
    end
    self:announce("I")
    if self:allReady() and self.saved.ledger[self.active.key .. "I"] then self:announce("G") end
    for key, time in pairs(self.saved.retired) do if self.cfg.wall() - time > 1800 then self.saved.retired[key] = nil end end
    for key, time in pairs(self.saved.ledger) do
        if key ~= self.active.key .. "I" and key ~= self.active.key .. "G" and self.cfg.wall() - time > 3600 then
            self.saved.ledger[key] = nil
            if self.saved.claims then self.saved.claims[key] = nil end
        end
    end
    self:changed()
end
