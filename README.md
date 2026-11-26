# ZKIR PARTY QUESTING

A party coordination addon for **WoW Forever 1.60.1**. It warns before **102 researched quest and NPC interactions**, including escorts, rituals, fights, and NPC departures. Coverage is not exhaustive.

**Install:** extract [version 1.3.2](https://github.com/Farwanda/ZKIR-party-questing/raw/refs/heads/main/dist/ZKIRPartyQuesting-1.3.2.zip) into `Interface/AddOns`, then restart WoW. The addon folder must be named `ZKIRPartyQuesting`. For updates, replace that folder and `/reload`. Existing settings are preserved.

Type **`/zkir`** for settings and **Preview warning**. During a supported interaction, a compact panel opens beside the quest dialogue. Short **WAIT** messages tell the party to stop. Readiness updates automatically; the leader checks **Unknown** players. When everyone is ready, the panel and PARTY chat give the next action. Players without the addon receive chat warnings. Normal game controls remain available.

**Loot:** Auto FFA is off by default. Outside dungeons, enable it for Battle.net friends, listed characters, or both. Every other party member must match an enabled option. When you lead an ordinary dungeon party, the addon switches to **Group Loot**, even with both FFA options off. Your FFA preferences remain saved.

Automated tests use simulations; this release still needs [in-game multiplayer checks](docs/MULTIPLAYER_CHECKLIST.md). See [loot details](docs/AUTO_LOOT.md) for limits and recovery behavior.
