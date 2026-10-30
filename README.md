# High Noon

An original cowboy multiplayer shooter for Roblox, built on the [Evostrike framework](https://github.com/beters02/Evostrike). High Noon is a working title chosen by Des.

The prototype is a frontier street shootout with one revolver, respawns, a scoreboard and a match result. The visual direction takes inspiration from cinematic Westerns and the atmosphere of Red Dead Redemption, with original characters, maps, music and final art planned for Josh.

## Prototype

- Two or more players start a free-for-all shootout: first to 10 eliminations, or highest score after three minutes.
- Six-shot revolver, server-checked shots and damage, headshots, distance falloff and timed reloads with an unlimited reserve for this prototype.
- Respawns, short spawn protection (lost on firing), live scores, match results and automatic next rounds.
- Grey frontier buildings and cover tagged `NeedsArt`, ready for Josh's art pass.
- First-person HUD and a grey camera revolver; firing and reload animation hooks are available for art integration.

Controls: WASD/stick to move, jump with the normal Roblox controls, click/tool activation to fire, R/gamepad X/touch Reload to reload. Mobile and gamepad controls are implemented but require device testing.

## Build and play

```sh
rojo build default.project.json -o "High Noon.rbxlx"
```

Open the resulting place in Roblox Studio. Play Solo shows the arena and waiting HUD; use two local test players to start combat. `aftman.toml` pins Rojo 7.4.0; this prototype was built with the installed Rojo 7.4.4.

The default project maps only the self-contained Western runtime under `western/`, art definitions under `src/shared/Config/AssetConfig.luau`, and Evostrike's standalone movement tuning module. It does not need the old UI, data stores, teleport destinations or shops. All upstream source remains preserved, and `evostrike.project.json` retains its original project mapping. That inherited mapping is incomplete without the original Studio assets.

The prototype reuses Evostrike's walking/jump tuning and adapts its damage multipliers/falloff approach; it does not yet port its full Source-style movement or weapon presentation systems. No player progress is saved in this milestone.

See [the milestone spec](docs/specs/SPEC-western-shooter.md), [validation notes](docs/VALIDATION.md), and [Josh's art requests](docs/ART-REQUESTS.md). Server analytics record match joined, completed and second match joined; Studio prints these events instead of sending live analytics.

## Credits and licence

Based on Evostrike by [beters02](https://github.com/beters02), who credits himself for programming, engine work, animations and some maps, and his brother [Donut](https://github.com/metr0nme) for assets. Evostrike cites [Fragsurf](https://github.com/Olezen/UnitySourceMovement) as a movement reference.

The [original README](docs/UPSTREAM-README.md) is preserved for full upstream context and links. The [GPL-2.0 licence](LICENSE.txt) remains included. Existing Evostrike assets are upstream work; Josh's future art will be credited separately.
