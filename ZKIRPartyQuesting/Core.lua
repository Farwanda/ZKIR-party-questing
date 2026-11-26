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

function Core:invalidate()
    self.manual, self.acknowledgements, self.pending = {}, {}, nil
    self.stableAt = self.cfg.now()
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
        if self.active and self.active.retiredRoster ~= signature then self.active.retiredRoster = nil end
        self:invalidate()
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
    if not self.healthy then return false end
    local parts = {"1", ...}
    for i, part in ipairs(parts) do
        if type(part) ~= "string" or part:find("[|\r\n]") then return false end
    end
    local payload = table.concat(parts, "|")
    if #payload > 255 then return false end
    local ok, sent = pcall(self.cfg.send, payload)
    if not ok or sent ~= true then
        self.healthy = false
        self.notice = "WAIT. Party sync failed."
        self:invalidate()
        return false
    end
    return true
end

function Core:adopt(a)
    if self.active and self.active.key ~= a.key then
        self.saved.retired[self.active.key] = self.cfg.wall()
    end
    self.active = a
    self.restoring = false
    self.facts, self.peers = {}, {}
    self.localFact = nil
    self.openedAt, self.lastPulse = self.cfg.now(), -100
    self.notice = nil
    self.healthy = true
    self:invalidate()
    self:changed()
end

function Core:detect(ruleID, context)
    if not NS.Rules[ruleID] then return end
    context = context or "unknown"
    if self.active and self.active.ruleID == ruleID and self.active.context == context then
        self:changed()
        return
    end
    self.serial = self.serial + 1
    local key = self.cfg.wall() .. "." .. self.cfg.boot .. "." .. self.serial .. "." .. NS.Hash(self.me)
    self:adopt({key = key, parent = self.active and self.active.key or "0", ruleID = ruleID,
        context = context, time = self.cfg.wall(), started = false})
    self:broadcast()
end

function Core:retry()
    if not self.active or self.cfg.now() - self.openedAt < DISCOVERY then return false end
    local a = self.active
    self.serial = self.serial + 1
    local key = self.cfg.wall() .. "." .. self.cfg.boot .. "." .. self.serial .. "." .. NS.Hash(self.me)
    self:adopt({key = key, parent = a.key, ruleID = a.ruleID, context = a.context,
        time = self.cfg.wall(), started = false})
    self:broadcast()
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
        self:invalidate()
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

function Core:rows()
    local rows, now = {}, self.cfg.now()
    local fingerprint = self:fingerprint()
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

function Core:allReady()
    if not self.active or self.active.started or not self.healthy or self.count == 0 then return false end
    if self.cfg.now() - self.stableAt < DISCOVERY then return false end
    for _, row in ipairs(self:rows()) do if row.status ~= "Ready" then return false end end
    return true
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
    a.started = true
    a.retiredRoster = (self.count or 0) > 1 and self.rosterSignature or nil
    self:invalidate()
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

function Core:receive(sender, payload)
    if sender == self.me or not self.roster[sender] or not self.roster[sender].connected or
        type(payload) ~= "string" or #payload > 255 then return end
    local p = split(payload)
    if p[1] ~= "1" then return end
    local kind, a = p[2], self.active
    if kind == "E" then
        if #p ~= 8 or not NS.Rules[p[5]] or not tonumber(p[7]) or (p[8] ~= "0" and p[8] ~= "1") or #p[3] > 100 or
            self.saved.retired[p[3]] or math.abs(self.cfg.wall() - tonumber(p[7])) > 1800 then return end
        if a and a.key == p[3] then
            self.restoring = false
            if p[8] == "1" and self:retire() then self:changed() end
            return
        end
        local concurrent = a and a.parent == p[4] and a.ruleID == p[5] and a.context == p[6]
        if concurrent and a.started and a.retiredRoster ~= self.rosterSignature then return end
        if p[8] == "1" then
            if not concurrent then return end -- Past actions cannot open or replace a warning.
            if self:retire() then self:changed() end
        end
        -- Server time is only a replay bound, never consensus or election ordering.
        local inherited = {}
        if concurrent then
            for _, stage in ipairs({"I", "G"}) do inherited[stage] = self.saved.ledger[a.key .. stage] end
        end
        if not a or self.restoring or not self.healthy or p[4] == a.key or (concurrent and p[3] < a.key) then
            self:adopt({key = p[3], parent = p[4], ruleID = p[5], context = p[6],
                time = tonumber(p[7]), started = p[8] == "1" or concurrent and a.started or false,
                retiredRoster = concurrent and a.retiredRoster or nil})
            for stage, timestamp in pairs(inherited) do self.saved.ledger[p[3] .. stage] = timestamp end
        end
        return
    end
    if not a or p[3] ~= a.key then return end
    if a.started and kind ~= "X" and kind ~= "L" then return end
    if kind == "H" and p[4] then
        local old = self.peers[sender]
        if not p[4]:match("^%d+%.?%d*$") or (old and olderBoot(p[4], old.boot)) then return end
        self.retiredBoots = self.retiredBoots or {}
        self.retiredBoots[sender] = self.retiredBoots[sender] or {}
        if self.retiredBoots[sender][p[4]] then return end
        if not old or old.boot ~= p[4] or old.expired then
            if old and old.boot ~= p[4] then self.retiredBoots[sender][old.boot] = true end
            self:invalidate()
            if not self.facts[sender] or self.facts[sender].state ~= "N" then self.facts[sender] = nil end
        end
        self.peers[sender] = {boot = p[4], at = self.cfg.now()}
    elseif kind == "F" and labels[p[6]] and p[7] and p[8] and tonumber(p[5]) then
        local peer, old = self.peers[sender], self.facts[sender]
        if not peer or peer.boot ~= p[4] or (old and old.boot == p[4] and old.seq >= tonumber(p[5])) then return end
        if old and old.state == "N" and p[6] == "U" then p[6], p[7] = "N", old.reason end
        if not old or old.signature ~= p[8] or old.state ~= p[6] then self:invalidate() end
        self.facts[sender] = {boot = p[4], seq = tonumber(p[5]), state = p[6], reason = p[7],
            signature = p[8], at = self.cfg.now()}
    elseif kind == "M" and sender == self.leader and self.roster[p[4]] and
        (p[5] == "R" or p[5] == "N") and p[6] == self:fingerprint() and tonumber(p[7]) then
        local old = self.manual[p[4]]
        if not old or tonumber(p[7]) > old.revision then
            self.manual[p[4]] = {state = p[5], fingerprint = p[6], revision = tonumber(p[7])}
        end
    elseif kind == "X" then
        self:retire()
    elseif kind == "L" and (p[4] == "I" or p[4] == "G") then
        self.saved.ledger[a.key .. p[4]] = self.cfg.wall()
        if self.saved.claims then self.saved.claims[a.key .. p[4]] = nil end
    elseif kind == "Q" and sender == self:owner() and p[5] == self:fingerprint() and
        (p[4] == "I" or (p[4] == "G" and self:allReady())) and self.healthy then
        -- Replicate the at-most-once claim BEFORE the sender attempts party chat.
        local slot = a.key .. p[4]
        if not self.saved.ledger[slot] or self.saved.claims and self.saved.claims[slot] == sender then
            self.saved.claims = self.saved.claims or {}
            self.saved.claims[slot] = sender
            self.saved.ledger[slot] = self.cfg.wall()
            self:send("K", a.key, p[4], p[5])
        end
    elseif kind == "K" and self.pending and p[4] == self.pending.stage and p[5] == self.pending.fingerprint then
        self.acknowledgements[sender] = true
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
            self:invalidate()
            self.healthy = false
            self.notice = "WAIT. An addon stopped responding. Reconnect, then /zkir retry."
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
