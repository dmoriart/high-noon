# High Noon

An original cowboy multiplayer shooter for Roblox, built on the [Evostrike framework](https://github.com/beters02/Evostrike). High Noon is a working title chosen by Des.

The proposed first playable version is a frontier street shootout with one revolver, respawns, a scoreboard and a match result. The visual direction takes inspiration from cinematic Westerns and the atmosphere of Red Dead Redemption, with original characters, maps, music and art by Josh.

## Current status

The Western conversion has started with project identity, planning and a dependency audit. The inherited game has not yet been built or playtested for this fork; this is not yet a playable Western release.

See [the milestone proposal](docs/specs/SPEC-western-shooter.md) and [Josh's proposed art requests](docs/ART-REQUESTS.md). Missing Studio scene and interface dependencies must be resolved before gameplay testing.

## Project setup

`default.project.json` maps the source into Roblox Studio using Rojo; `aftman.toml` pins Rojo 7.4.0. A source build alone does not supply all inherited Studio models, interfaces and maps. Existing teleport destinations also need to be replaced with places owned by this project before travel is tested.

## Credits and licence

Based on Evostrike by [beters02](https://github.com/beters02), who credits himself for programming, engine work, animations and some maps, and his brother [Donut](https://github.com/metr0nme) for assets. Evostrike cites [Fragsurf](https://github.com/Olezen/UnitySourceMovement) as a movement reference.

The [original README](docs/UPSTREAM-README.md) is preserved for full upstream context and links. The [GPL-2.0 licence](LICENSE.txt) remains included. Existing Evostrike assets are upstream work; Josh's future art will be credited separately.
