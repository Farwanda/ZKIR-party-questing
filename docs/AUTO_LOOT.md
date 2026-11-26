# Automatic loot — version 1.3

Open `/zkir`. **With Battle.net friends** and **With these characters** control outdoor FFA. They are independent, per-character options, both off by default. Every other member must match at least one enabled option; one friend does not authorize FFA for a party containing strangers. The leader is excluded from the friendship check. Other members do not need the addon. Ordinary dungeon parties use Group Loot instead, regardless of these options.

**Characters...** accepts up to 100 distinct names, one `Name-Realm` per line. A bare name expands to the current realm. Realm spaces are normalized, names are stored as lowercase keys, and matching includes the realm. Saving does not enable the option. Invalid input leaves the old list intact; Cancel/Escape discards edits.

## Outdoor FFA

- You must be the actual leader of an ordinary home party of 2–5, outside an instance (`IsInInstance()` returns `false, "none"`). Solo, raids and instance-matchmade groups are excluded. Missing, secret or unsupported location information prevents new loot requests.
- Every identity must be readable and distinct, every member connected, and every other member trusted. Battle.net must be connected and the exact party member's player GUID must resolve to an account with `isFriend == true`. Merely finding an account, matching a display name, or finding a different active character is insufficient.
- Activation waits for two seconds of stable identity/trust, no party combat, no local looting, no known game restriction, and an available FFA method. Missing or secret required evidence defers the change. Repeated roster notifications alone do not restart that wait.
- The addon captures a known Group Loot, Round Robin, Need Before Greed or Master Loot baseline. Master Loot requires an identified master looter. It calls `C_PartyInfo.SetLootMethod` once and checks the server-visible result. A rejected call cannot establish ownership; unconfirmed requests stop after five seconds without repeated attempts for the same state. No loot threshold is changed.

Only this client's leader policy acts. Neither loot policy sends party announcements, addon messages, account-name logs, or automatically distributes items. FFA permits ordinary manual looting; it is not a credit or loot-allocation guarantee.

## Dungeon Group Loot

When `IsInInstance()` returns `true, "party"`, the current leader of an ordinary home party of 2–5 requests **Group Loot**. Dungeon detection uses the current leader client's location. This policy applies even with both FFA options off, untrusted or disconnected members, manually selected FFA, or an existing outdoor automation pause. It does not require friend data or complete member identities. Solo, raid and matchmade groups remain excluded; a nonleader never changes loot.

The request waits for local combat, looting and game restrictions to clear, and for the Group Loot method to be available. It does not wait for remote members' combat state or the outdoor two-second trust check. If a request was already issued outdoors, its confirmation or timeout is handled before choosing Group Loot. Missing or secret location data cannot authorize a new request.

Each request is checked against the actual loot method. A rejection or five-second confirmation timeout stops repeated requests for that state and asks for manual review. Toggle an Auto FFA checkbox, enter/leave a dungeon, or form a new party to permit a retry. Unrelated roster notifications, sound settings and quest updates do not retry it. Once confirmed, Group Loot needs no further requests unless the method changes again.

Group Loot takes priority over manual selections inside a dungeon: a later FFA or other loot selection is corrected when safe. An existing manual/interrupted pause is retained for outdoor FFA. Dungeon Group Loot discards any old FFA restoration baseline; leaving the dungeon does not restore that old method. Outside again, eligible FFA can resume after its normal two-second check, using Group Loot as its new baseline, unless a manual/interrupted pause requires review. FFA preferences are unchanged.

## Manual control and recovery

A detected manual method change pauses **outdoor FFA**, even across a reload. Changing sound, window size or unrelated quests does not resume it. After reviewing party loot, change an Auto FFA checkbox to resume. A known new party also clears the pause. Outdoors, FFA already set by someone else remains under manual control and is never restored by this addon. Inside a dungeon, the Group Loot policy above still applies.

Outdoors, if the addon owns the FFA change and eligibility ends, a member disconnects, Battle.net evidence disappears, or both options are turned off, it attempts to restore the captured method while you still lead the same continuous party. Restoration waits for local combat, looting and game restrictions to clear; it does not wait for another member's combat state. Master Loot restoration resolves the original master by GUID and verifies that person in the resulting method. If that person is gone or restoration fails, the settings window and a local notice ask you to choose loot manually. Entering a dungeon selects Group Loot instead of starting an old-baseline restoration.

Ownership and restore instructions are deliberately **not resumed after `/reload`, relogging, leaving, or a leadership interruption**. There is no reliable getter that proves ordinary party continuity after reload. A persisted marker instead asks for manual review; toggling an option resumes fresh outdoor evaluation. This can leave FFA active outdoors until someone changes it manually. Fresh dungeon Group Loot checks still apply after reload or a leadership change, without reusing old restoration instructions. If authority or the current method is unreadable, the addon waits rather than claiming a successful change. It never promises an unconditional restoration.

Normal game controls are preserved. A same-method selection with no observable state change cannot be distinguished from leaving the current method alone. Other loot automation should be disabled to avoid conflicting policies.

## Evidence and limits

The supplied development log from Forever **1.60.1 / build 71091 / interface 16001** confirmed GUID-based friend lookup and one delayed Group Loot → FFA → Group Loot probe in a connected, out-of-combat, two-player outdoor party led by the tester. The loot threshold stayed unchanged. Roster-update events also occurred on loot changes without a membership change. These observations support the APIs; they do **not** field-verify this production policy, other baselines, alternate characters, leader transfers, restrictions, dungeon behavior, or 3–5-player groups.

The production implementation has Lua 5.1 simulations for eligibility, mixed parties, missing/secret APIs, restrictions, manual changes, pending-event races, identity replacement, restoration, settings and reload safety. Version 1.3's dungeon priority and dungeon/outdoor transitions are **simulation-tested only**; the supplied log contains no dungeon test. Visual layout and actual multiplayer operation still require the [field checklist](MULTIPLAYER_CHECKLIST.md).

API reference checked against the Forever branch of Blizzard's generated UI documentation:

- [PartyInfo](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/PartyInfoDocumentation.lua): enum-based loot methods, availability, setter result and party lifecycle events.
- [Instance](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/InstanceDocumentation.lua): `IsInInstance` returns the instance-presence boolean and instance-type string used for location checks.
- [BattleNet](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/BattleNetDocumentation.lua): account lookup by player GUID and friendship evidence.
- [RestrictedActions](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/RestrictedActionsDocumentation.lua): restriction state and events; both activating and active states defer changes.

Development logging, diagnostic commands, and probe controls are absent from this release. Old diagnostic SavedVariables are discarded on load, retaining only a manual-review warning for an unfinished probe. The user-supplied `log.txt` is excluded from Git and the install ZIP. Character settings and small recovery markers stay in this character's SavedVariables; no BattleTags or friend-account identifiers are stored by this feature.
