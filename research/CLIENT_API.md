# Forever client/API verification — 23 November 2026

Research target: **Forever 1.60.1 / interface 16001**, as reviewed on 23 November 2026. Sources: [Questie's Forever TOC](https://github.com/Questie/Questie/blob/master/Questie_Forever.toc), [Questie releases](https://github.com/Questie/Questie/releases), and [Gethe Forever UI source](https://github.com/Gethe/wow-ui-source/tree/forever). Third-party database pages identify build 71037; this machine has no game installation. These are source findings, not live-client verification. Recheck them before rebuilding.

The addon implementation has been removed. The notes below retain useful API implications; former constants, UI choices, and readiness policies are not requirements for a future implementation.

| Area | Source contract reviewed | Notes for future implementation |
| --- | --- | --- |
| Pre-accept | `QUEST_DETAIL` opens the quest detail UI; `GetQuestID()` supplies identity. | Warn synchronously at this event; optionally earlier on an exact `C_GossipInfo.GetAvailableQuests()` offer. |
| Pre-turn-in | `QUEST_PROGRESS` and `QUEST_COMPLETE` are quest/reward UI stages before handing in. | Warn on both; never use `QUEST_TURNED_IN` as the initial warning. |
| Dialogue | `GOSSIP_SHOW`, `C_GossipInfo.GetAvailableQuests()`, numeric NPC GUID entry. | NPC-scoped warning at conversation open; no guessed option IDs or click interception. |
| Acceptance | Forever `QUEST_ACCEPTED` has **one quest-ID argument**, unlike the Classic index-plus-ID contract. | Read the first argument. |
| Group offer | `QUEST_ACCEPT_CONFIRM(name, questTitle, questID)`; title is not the identifier. | Read third argument, show invitation status, then observe actual log entry. No `QUEST_CONFIRM_ACCEPT` event is assumed. |
| Hand-in | `QUEST_TURNED_IN(questID, xpReward, moneyReward)` and `C_QuestLog.IsQuestFlaggedCompleted(id)`. | Distinguish rewarded from log objectives complete. |
| Quest log | `C_QuestLog.GetLogIndexForQuestID`, `IsFailed`, `IsComplete`. | Missing/API failure/secret values stay distinct. Never infer rewarded from disappearance or objective counts. |
| Capacity | `GetNumQuestLogEntries()` returns shown entries then **quest count**; `GetMaxNumQuestsCanAccept()` is the standard accepted-quest limit. | Use second return and standard limit; never assume 20/25 or use the broader hidden-quest maximum. Only acceptance checks require a slot. |
| Roster | `UnitGUID`, `UnitFullName`, `UnitIsGroupLeader`, `UnitIsConnected`, party unit tokens. | Roster is authority. Sender names resolve to its stable GUIDs; ambiguous short names fail closed. |
| Addon registration | `C_ChatInfo.RegisterAddonMessagePrefix(prefix)` returns `RegisterAddonMessagePrefixResult`, including Success=0, DuplicatePrefix=1. | Handle enum values explicitly; choose a short ASCII prefix. |
| Addon send | `C_ChatInfo.SendAddonMessage(prefix, message, chatType, target?)` returns `SendAddonMessageResult`, **not a simple success Boolean**. | Handle Success=0 explicitly; errors cannot establish peer status. The previous 255-byte packet bound and 0.3-second send spacing were conservative implementation choices, not a measured throughput guarantee. |
| Ordinary party chat | `C_ChatInfo.SendChatMessage(message, chatType, languageID?, target?)` has restrictions and no return values. | Check lockdown and handle errors. A call without an immediate error does not certify delivery. Whether automatic messages work in each intended context still needs a live test; this API research does not require a leader-click button. |
| Restrictions | Send API disallows secret arguments; result enum includes throttle, invalid message, not-in-group and AddOnMessageLockdown=11. `InChatMessagingLockdown()` is available. | Skip lockdown and guard calls. No alternate-channel workaround. State expires. |
| Secret data | Forever source and current addon changelogs describe secret creature identifiers in dungeon contexts. | `issecretvalue` before branching/string operations; `pcall` around API collection. No tooltip/proximity workaround. |
| UI/runtime | Ordinary `CreateFrame`, `BackdropTemplate`, font strings, `C_Timer.NewTicker`, `PlaySound` are available in the reviewed source. | A future advisory UI need not call protected game-action functions. Layout requires in-game visual testing. |

Source files inspected:

- [ChatInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChatInfoDocumentation.lua)
- [ChatConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChatConstantsDocumentation.lua)
- [QuestLogDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua)
- [QuestOfferDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestOfferDocumentation.lua)
- [GossipInfoDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/GossipInfoDocumentation.lua)
- [QuestFrame.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/QuestFrame.lua), including its pre-action event handlers.
- [Questie Forever development observations](https://github.com/Questie/Questie/blob/master/docs/forever-development.md) and [quest completion semantics](https://github.com/Questie/Questie/blob/master/docs/quest-completion-semantics.md). These report that `GetQuestLogTitle` and global `IsQuestComplete` are absent on observed Forever builds; prefer the documented namespace methods.

Changing the TOC alone is not a compatibility port. A future implementation must handle unavailable or restricted APIs without converting missing information into readiness. Exact server invitation range, restricted-instance communication behavior, automatic party-chat delivery, and custom UI timing remain field checks.
