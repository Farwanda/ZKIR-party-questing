# ZKIR PARTY QUESTING

A small addon for questing with friends in **WoW Forever 1.60.1**. It warns before 102 researched quest and NPC interactions, including escorts, fights, rituals, and NPC departures.

## Install

Extract [version 1.3.3](https://github.com/Farwanda/ZKIR-party-questing/raw/refs/heads/main/dist/ZKIRPartyQuesting-1.3.3.zip) into `Interface/AddOns`, then restart WoW. The folder must be `Interface/AddOns/ZKIRPartyQuesting`, with `ZKIRPartyQuesting.toc` directly inside. For updates, replace that folder and `/reload`.

## Use

Type **`/zkir`** for settings and **Preview warning**. Supported interactions open a compact panel beside the quest dialogue. Short **WAIT** messages tell the party to stop. Readiness updates automatically; the leader can confirm missing information. Once everyone is ready, the panel and PARTY chat give the next action.

Install on each player's client for automatic quest checks. Members without the addon receive chat warnings. Solo warnings and ordinary parties of 2–5 are supported. Quest acceptance and dialogue remain under your control.

## Loot

Outdoor **Auto FFA is off by default**. Enable it for Battle.net friends, listed characters, or both; every other member must match an enabled option. As dungeon party leader, the addon requests **Group Loot**, even with both FFA options off.

Outdoors, losing eligibility attempts to restore the previous loot method. A manual change pauses Auto FFA; toggle an FFA option to resume. Reloads or leadership interruptions discard restoration instructions: check loot manually, as FFA may remain active outdoors.

## Help and development

Coverage is incomplete; readiness cannot guarantee quest credit. Automated tests pass; [live multiplayer checks](docs/TESTING.md) remain outstanding.

[Report a bug](https://github.com/Farwanda/ZKIR-party-questing/issues) · [Changelog](CHANGELOG.md) · [Build and test](docs/TESTING.md) · [MIT license](LICENSE)
