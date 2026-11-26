-- Native dialogue observations. A displayed menu can outlive the current menu
-- until the next frame because secure selection hooks run after the game call.
local _, NS = ...
local Context = {}
Context.__index = Context
local public, read, field = NS.API.public, NS.API.read, NS.API.field

function NS.NewInteractionContext(now)
    return setmetatable({now = now, hookedFrames = {}}, Context)
end

function Context:reset()
    self.quest, self.gossip, self.displayed = nil, nil, nil
end

function Context:target()
    local guid = read(UnitGUID, "npc")
    if type(guid) ~= "string" then return nil, nil end
    local kind, id = guid:match("^([^-]+)%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)%-")
    if kind == "GameObject" then return guid, nil end -- quest context, never an NPC gossip match
    if kind ~= "Creature" and kind ~= "Vehicle" then return nil, nil end
    return guid, tonumber(id)
end

local function gossipOptions()
    -- Public IDs distinguish choices across locales, not their event meanings.
    local options = read(C_GossipInfo and C_GossipInfo.GetOptions)
    if type(options) ~= "table" then return end
    local ids, byIndex, sorted = {}, {}, {}
    for _, option in ipairs(options) do
        local id, index = field(option, "gossipOptionID"), field(option, "orderIndex")
        if type(id) ~= "number" or id < 0 or id % 1 ~= 0 or ids[id] then return end
        ids[id], sorted[#sorted + 1] = true, id
        if type(index) == "number" and index >= 0 and index % 1 == 0 then byIndex[index] = id end
    end
    if #sorted == 0 then return end
    table.sort(sorted)
    return ids, byIndex, NS.Hash(table.concat(sorted, ","))
end

function Context:observeQuest()
    self.quest = {guid = self:target(), questID = read(GetQuestID)}
    return self.quest.questID
end

function Context:observeGossip()
    local guid, npcID = self:target()
    local previous = self.gossip
    local dialog = {guid = guid, npcID = npcID, offers = {}}
    dialog.ids, dialog.byIndex, dialog.stage = gossipOptions()
    -- The first available IDs establish a baseline, not evidence of a new choice.
    if previous and previous.guid == guid then dialog.previousStage = previous.stage or previous.previousStage end
    self.gossip = dialog
    if not self.displayed then self.displayed = dialog end
    local offers = read(C_GossipInfo and C_GossipInfo.GetAvailableQuests)
    local upcoming = {}
    if type(offers) == "table" then
        for _, offer in ipairs(offers) do
            local id = field(offer, "questID")
            if type(id) == "number" and NS.Rules["a" .. id] and not dialog.offers[id] then
                dialog.offers[id] = true
                upcoming[#upcoming + 1] = id
            end
        end
    end
    return upcoming
end

function Context:identity(ruleID, guid, active)
    local context, dialog = guid or "unknown", self.gossip
    if NS.Rules[ruleID].kind == "gossip" and dialog then
        local bare = active and active.ruleID == ruleID and active.context == context
        if dialog.stage and (not bare or dialog.previousStage and dialog.previousStage ~= dialog.stage) then
            context = context .. ":g" .. dialog.stage
        elseif active and active.ruleID == ruleID and active.context:match("^(.-):g%d+$") == guid then
            -- Missing IDs are not evidence that another stage has begun.
            context = active.context
        end
        dialog.context = context
    end
    return context
end

function Context:closeQuest() self.quest = nil end
function Context:closeGossip()
    if self.gossip then self.gossip.closedAt = self.now() end
end

function Context:commitDisplayed()
    self.displayed = self.gossip
end

function Context:matchesSelection(active, method, option)
    local dialog = self.displayed
    if not active or not dialog or not public(option) then return false end
    if self.gossip and self.gossip.guid ~= dialog.guid then return false end
    -- Native selection may close the frame and clear UnitGUID("npc") before
    -- the post-hook. Keep the captured interaction briefly for that callback.
    if dialog.closedAt and self.now() - dialog.closedAt > 1 then return false end
    if dialog.ids then
        local id = option
        if method == "SelectOptionByIndex" then id = dialog.byIndex[option] end
        if not dialog.ids[id] then return false end
    end
    local rule = NS.Rules[active.ruleID]
    return rule.kind == "gossip" and rule.npcID == dialog.npcID and active.context == dialog.context
end

function Context:anchor(active, refresh)
    -- Native panels may appear after our event handler, or be loaded later.
    for _, panel in pairs({quest = QuestFrame, gossip = GossipFrame}) do
        if not self.hookedFrames[panel] and type(panel.HookScript) == "function" then
            self.hookedFrames[panel] = true
            panel:HookScript("OnShow", refresh)
            panel:HookScript("OnHide", function()
                if panel == GossipFrame then self:closeGossip() end
                refresh()
            end)
        end
    end
    if not active then return end
    local rule, guid = NS.Rules[active.ruleID], self:target()
    local quest, gossip = self.quest, self.gossip
    if quest and quest.guid == active.context and guid == quest.guid and rule.kind ~= "gossip" and
        quest.questID == rule.questID and QuestFrame and read(QuestFrame.IsShown, QuestFrame) == true then
        return QuestFrame
    end
    if gossip and (rule.kind == "gossip" and gossip.context or gossip.guid) == active.context and guid == gossip.guid and
        GossipFrame and read(GossipFrame.IsShown, GossipFrame) == true and
        (rule.kind == "gossip" and rule.npcID == gossip.npcID or rule.kind == "accept" and gossip.offers[rule.questID]) then
        return GossipFrame
    end
end
