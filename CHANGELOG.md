# Changelog

## 1.3.3

- Refactored coordination, dialogue tracking, loot state, and rendering while preserving gameplay behavior and saved settings.
- Improved simulated coverage of dialogue transitions and loot initialization.
- Simplified documentation and prepared the package for public distribution.

## 1.3.2

- Fixed completed solo interactions blocking fresh party coordination.
- Added fresh checks when public dialogue choices change.
- Fixed accented and Cyrillic character-list matching through the game's comparison API.

## 1.3.1

- Dungeon parties use Group Loot when this client is the leader.
- Completed solo actions no longer queue a warning for a later party.

Earlier history is available in Git. See [testing](docs/TESTING.md) for simulations and outstanding live checks.
