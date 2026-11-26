local ADDON, NS = ...
local PREFIX = "ZKIRPQ1"
local engine, registered, elapsed = nil, false, 0
local batchDepth, renderPending = 0, false
local questDialog, gossipDialog
local hookedFrames = {}

local public, call = NS.API.public, NS.API.read
local function boolean(value)
    if public(value) and type(value) == "boolean" then return value end
end
local function now() return call(GetTime) or 0 end
local function wall() return call(GetServerTime) or call(time) or 0 end
function NS.QuestTitle(id)
    local title = call(C_QuestLog and C_QuestLog.GetTitleForQuestID, id)
    if type(title) == "string" and title ~= "" then return title end
end
local function fullName(unit)
    local name, realm = call(UnitFullName, unit)
    if type(name) ~= "string" or name == "" then return nil end
    if not realm or realm == "" then realm = call(GetNormalizedRealmName) end
    if type(realm) ~= "string" or realm == "" then return nil end
    return name .. "-" .. realm:gsub("%s", "")
end
local function party()
    return call(IsInRaid) == false and (call(GetNumSubgroupMembers) or 0) > 0
end
local function locked()
    if type(InChatMessagingLockdown) == "function" then return call(InChatMessagingLockdown) ~= false end
    return false
end
function NS.PlayWarningSound()
    if not NS.Settings.values.sound then return end
    local kit = SOUNDKIT and SOUNDKIT.RAID_WARNING
    if not public(kit) or type(kit) ~= "number" then return end
    if C_Sound and type(C_Sound.PlaySound) == "function" then
        call(C_Sound.PlaySound, kit)
    else
        call(PlaySound, kit, "Master")
    end
end
local function status()
    if not engine then return "Loaded, but player identity is unavailable. Try again after entering the world." end
    if call(IsInRaid) == true then return "Raids are not supported. Use a party of 2–5." end
    if not registered or type(C_ChatInfo and C_ChatInfo.SendAddonMessage) ~= "function" then
        return "Party messaging is unavailable. Local warnings still work."
    end
    if type(C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage) ~= "function" then
        return "Party chat is unavailable. Local warnings still work."
    end
    if locked() then return "Party messaging is restricted. Wait before starting." end
    if engine.notice then return engine.notice end
    if not engine.healthy then return "Party synchronization is unavailable. Wait before starting." end
    if engine.active then
        local title = NS.Rules[engine.active.ruleID].title
        return (engine.active.started and "Action observed: " or "Coordinating: ") .. title
    end
    return "Waiting for a supported interaction." ..
        (engine.count == 1 and not NS.Settings.values.solo and "\nSolo warnings are off; party warnings remain automatic." or "")
end
local function send(payload)
    if not registered or not party() or locked() then return false end
    local result = call(C_ChatInfo and C_ChatInfo.SendAddonMessage, PREFIX, payload, "PARTY")
    local success = Enum and Enum.SendAddonMessageResult and Enum.SendAddonMessageResult.Success or 0
    return result == success or result == true
end
local function chat(text)
    if not party() or locked() or #text > 255 then return false end
    local fn = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
    if type(fn) ~= "function" then return false end
    local ok = pcall(fn, text, "PARTY")
    return ok -- This API has no delivery acknowledgement; never retry the announcement.
end
local function roster()
    if not engine then return end
    if call(IsInRaid) == true then
        engine:setRoster({})
        engine.healthy = false
        engine.notice = "ZKIR supports solo and parties of 2–5; raids are not supported."
        return
    end
    local list = {{name = engine.me, connected = boolean(call(UnitIsConnected, "player")),
        leader = not party() or call(UnitIsGroupLeader, "player") == true}}
    for i = 1, (call(GetNumSubgroupMembers) or 0) do
        local unit = "party" .. i
        local name = fullName(unit)
        list[#list + 1] = {name = name or ("Unidentified party member " .. i),
            leader = call(UnitIsGroupLeader, unit) == true,
            connected = name and boolean(call(UnitIsConnected, unit))}
    end
    engine:setRoster(list)
end
local function quest(id)
    local api = C_QuestLog or {}
    return {rewarded = boolean(call(api.IsQuestFlaggedCompleted, id)),
        active = boolean(call(api.IsOnQuest, id)), failed = boolean(call(api.IsFailed, id)),
        complete = boolean(call(api.IsComplete, id))}
end
local function evaluate()
    if not engine or not engine.active or engine.active.started then return end
    local rule = NS.Rules[engine.active.ruleID]
    local api = C_QuestLog or {}
    local _, count = call(api.GetNumQuestLogEntries or GetNumQuestLogEntries)
    local maximum = call(api.GetMaxNumQuestsCanAccept or GetMaxNumQuestsCanAccept)
    local snapshot = {quests = {}, level = call(UnitLevel, "player"), faction = call(UnitFactionGroup, "player")}
    local _, _, classID = call(UnitClass, "player")
    local _, _, raceID = call(UnitRace, "player")
    snapshot.classID, snapshot.raceID = classID, raceID
    if type(count) == "number" and type(maximum) == "number" then snapshot.space = count < maximum end
    if rule.questID then snapshot.quests[rule.questID] = quest(rule.questID) end
    if rule.afterQuestID then snapshot.quests[rule.afterQuestID] = quest(rule.afterQuestID) end
    for _, id in ipairs(rule.prerequisites) do snapshot.quests[id] = quest(id) end
    for _, id in ipairs(rule.exclusive or {}) do snapshot.quests[id] = quest(id) end
    engine:setFact(NS.Evaluate(rule, snapshot))
end
local function npc()
    local guid = call(UnitGUID, "npc")
    if type(guid) ~= "string" then return nil, nil end
    local kind, id = guid:match("^([^-]+)%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)%-")
    if kind == "GameObject" then return guid, nil end -- quest context, never an NPC gossip match
    if kind ~= "Creature" and kind ~= "Vehicle" then return nil, nil end
    return guid, tonumber(id)
end
local function refreshAnchor()
    -- Native panels may appear after our event handler, or be loaded later.
    for _, panel in pairs({quest = QuestFrame, gossip = GossipFrame}) do
        if not hookedFrames[panel] and type(panel.HookScript) == "function" then
            hookedFrames[panel] = true
            panel:HookScript("OnShow", refreshAnchor)
            panel:HookScript("OnHide", function()
                if panel == GossipFrame and gossipDialog then gossipDialog.closedAt = now() end
                refreshAnchor()
            end)
        end
    end
    local active, anchor = engine and engine.active
    if active then
        local rule = NS.Rules[active.ruleID]
        local guid = npc()
        if questDialog and questDialog.guid == active.context and guid == questDialog.guid and
            rule.kind ~= "gossip" and questDialog.questID == rule.questID and
            QuestFrame and call(QuestFrame.IsShown, QuestFrame) == true then
            anchor = QuestFrame
        elseif gossipDialog and gossipDialog.guid == active.context and guid == gossipDialog.guid and
            GossipFrame and call(GossipFrame.IsShown, GossipFrame) == true and
            (rule.kind == "gossip" and rule.npcID == gossipDialog.npcID or
             rule.kind == "accept" and gossipDialog.offers[rule.questID]) then
            anchor = GossipFrame
        end
    end
    NS.UI.setAnchor(anchor)
end
local function present()
    refreshAnchor()
    if renderPending then
        renderPending = false
        NS.UI.update(engine)
    end
    NS.Settings.refresh()
end
local function detect(kind, questID)
    if not engine then return end
    local guid, npcID = npc()
    for id, rule in pairs(NS.Rules) do
        if rule.kind == kind and (not rule.requireActiveToDetect or quest(rule.questID).active ~= false) and
            (not rule.afterQuestID or quest(rule.afterQuestID).rewarded ~= false) and
            ((kind == "gossip" and rule.npcID == npcID) or
            (kind ~= "gossip" and rule.questID == questID)) then
            engine:detect(id, guid or "unknown")
            evaluate()
            return
        end
    end
end
local function start()
    if engine then return end
    ZKIRPartyQuestingDB = type(ZKIRPartyQuestingDB) == "table" and ZKIRPartyQuestingDB or {}
    local db = ZKIRPartyQuestingDB
    local version = call(C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata, ADDON, "Version")
    NS.Settings.init(db, {status = status, version = type(version) == "string" and version or "unknown",
        changed = function() NS.UI.applySettings(); NS.AutoLoot.settingsChanged() end})
    NS.AutoLoot.init(db)
    local me = fullName("player")
    if not me then return end
    db.boot = (tonumber(db.boot) or 0) + 1
    db.engine = type(db.engine) == "table" and db.engine or {}
    local result = call(C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix, PREFIX)
    local enum = Enum and Enum.RegisterAddonMessagePrefixResult or {}
    registered = result == true or result == (enum.Success or 0) or result == (enum.DuplicatePrefix or 1)
    engine = NS.New({me = me, now = now, wall = wall, boot = tostring(wall()) .. "." .. db.boot,
        saved = db.engine, send = send, chat = chat, changed = function()
            renderPending = true
            if batchDepth == 0 then present() end
        end})
    NS.engine = engine
    roster()
    evaluate()
end
local function senderName(sender)
    if not public(sender) or type(sender) ~= "string" then return nil end
    if engine.roster[sender] then return sender end
    if sender:find("-", 1, true) then return nil end
    local result
    for name in pairs(engine.roster) do
        if name:match("^[^-]+") == sender then
            if result then return nil end -- ambiguous short names cannot establish authority
            result = name
        end
    end
    return result
end
local driver = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE", "UNIT_CONNECTION",
    "PARTY_LEADER_CHANGED", "QUEST_DETAIL", "QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_LOG_UPDATE",
    "QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_ACCEPT_CONFIRM", "GOSSIP_SHOW", "CHAT_MSG_ADDON",
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "PARTY_LOOT_METHOD_CHANGED", "GROUP_JOINED",
    "GROUP_FORMED", "GROUP_LEFT", "ADDON_RESTRICTION_STATE_CHANGED", "QUEST_FINISHED", "GOSSIP_CLOSED"}) do
    pcall(driver.RegisterEvent, driver, event)
end
local function handleEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then questDialog, gossipDialog = nil, nil end
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then start(); roster() end
    NS.AutoLoot.event(event, ...)
    if not engine then return end
    local a, b, channel, sender = ...
    if event == "CHAT_MSG_ADDON" then
        if public(a) and public(channel) and public(b) and a == PREFIX and channel == "PARTY" then
            engine:receive(senderName(sender), b)
            evaluate()
        end
    elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
        if not public(a) or type(a) ~= "string" then return end
        local author = senderName(b)
        if a == "ZKIR status" then engine:chatHelp(author); return end
        local token, choice, name = a:match("^ZKIR (%d+) (%l+) (.+)$")
        local lineID = select(11, ...)
        if token and (choice == "ready" or choice == "notready") and public(lineID) then
            engine:confirmFromChat(author, token, senderName(name), choice == "ready" and "R" or "N", lineID)
        end
    elseif event == "QUEST_DETAIL" or event == "QUEST_PROGRESS" or event == "QUEST_COMPLETE" then
        questDialog = {guid = npc(), questID = call(GetQuestID)}
        detect(event == "QUEST_DETAIL" and "accept" or "turnin", questDialog.questID)
    elseif event == "GOSSIP_SHOW" then
        local guid, npcID = npc()
        gossipDialog = {guid = guid, npcID = npcID, offers = {}}
        detect("gossip")
        local offers = call(C_GossipInfo and C_GossipInfo.GetAvailableQuests)
        local upcoming, seen = {}, {}
        if type(offers) == "table" then
            for _, offer in ipairs(offers) do
                if public(offer) and type(offer) == "table" and public(offer.questID) and
                    type(offer.questID) == "number" and NS.Rules["a" .. offer.questID] and not seen[offer.questID] then
                    seen[offer.questID] = true
                    gossipDialog.offers[offer.questID] = true
                    upcoming[#upcoming + 1] = offer.questID
                end
            end
        end
        -- Multiple hazardous offers (e.g. Volcor's alternatives) do not identify
        -- the upcoming action. QUEST_DETAIL warns as soon as the player picks one.
        if #upcoming == 1 then detect("accept", upcoming[1]) end
    elseif event == "QUEST_ACCEPTED" or event == "QUEST_TURNED_IN" then
        if public(a) then engine:action(a, event == "QUEST_ACCEPTED" and "accept" or "turnin") end
        evaluate()
    elseif event == "QUEST_ACCEPT_CONFIRM" then
        if public(channel) and engine.active and NS.Rules[engine.active.ruleID].questID == channel then
            engine:action(channel, "accept")
            engine.notice = "Quest invite received. Use the game prompt."
            renderPending = true
        end
    elseif event == "QUEST_FINISHED" then questDialog = nil
    elseif event == "GOSSIP_CLOSED" then
        if gossipDialog then gossipDialog.closedAt = now() end
    elseif event == "QUEST_LOG_UPDATE" then evaluate()
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LEADER_CHANGED" or event == "UNIT_CONNECTION" then
        roster(); evaluate()
    end
end
driver:SetScript("OnEvent", function(_, event, ...)
    batchDepth = batchDepth + 1
    handleEvent(event, ...)
    batchDepth = batchDepth - 1
    if batchDepth == 0 then present() end
end)
driver:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed < 0.5 then return end
    elapsed = 0
    batchDepth = batchDepth + 1
    if engine then evaluate(); engine:tick() end
    NS.AutoLoot.tick()
    batchDepth = batchDepth - 1
    if batchDepth == 0 then present() end
end)
-- Observation only, after the ordinary control runs. No guessed gossip option IDs.
if type(hooksecurefunc) == "function" and C_GossipInfo then
    local function selected()
        if not engine or not engine.active or not gossipDialog then return end
        local rule = NS.Rules[engine.active.ruleID]
        -- The native selection can close the panel and clear UnitGUID("npc")
        -- before this post-hook. Use the captured interaction for that callback.
        if gossipDialog.closedAt and now() - gossipDialog.closedAt > 1 then return end
        if rule.kind == "gossip" and rule.npcID == gossipDialog.npcID and
            engine.active.context == gossipDialog.guid then engine:action(rule.questID, "gossip") end
    end
    for _, method in ipairs({"SelectOption", "SelectOptionByIndex"}) do
        if type(C_GossipInfo[method]) == "function" then pcall(hooksecurefunc, C_GossipInfo, method, selected) end
    end
end
SLASH_ZKIRPARTYQUESTING1 = "/zkir"
SlashCmdList.ZKIRPARTYQUESTING = function(command)
    start()
    command = (command or ""):lower():match("^%s*(.-)%s*$")
    if command == "" or command == "settings" or not engine then NS.Settings.show()
    elseif command == "retry" then
        engine:retry(); evaluate()
        if engine.active then NS.UI.show(engine) else NS.Settings.show() end
    elseif command == "show" then
        if engine.active then NS.UI.show(engine) else NS.Settings.show() end
    elseif DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("ZKIR: " .. (command == "status" and status() or
            "Commands: /zkir (settings), /zkir show, /zkir retry (new attempt), /zkir status"))
    end
end
