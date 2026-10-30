# First friends playtest — art handoff and controls

Date: 2026-10-30. Des requested continued improvements so a small playtest can follow a few art deliveries.

We believe new players will complete a first shootout because firing/reloading have clear controls and feedback, and Josh's first assets can replace the greybox without rewriting combat. We'll know if four of five testers fire and reload without help and at least half stay for another round. Log first accepted shot and first completed reload once per player per match, alongside the existing join/completion/replay events.

## This milestone

- Add named optional model slots for the revolver, reusable 16-stud storefront, 20-stud saloon, crate and barrel. Blank slots keep greybox art; configured missing/invalid models fail clearly. Preserve source art, clone it at runtime, and keep the tested greybox collision separate from cosmetic meshes.
- Support first-person revolver fire/reload animation IDs and optional fire/reload/hit sound IDs through AssetConfig. Blank media slots create no invalid loads. Final clips/ownership are verified after Josh supplies them.
- Add explicit touch/gamepad Fire, client fire debouncing, a server-timed reload progress display and correct waiting/preparing/intermission hints. Server validation remains authoritative.
- Create an ordered art checklist with dimensions, pivots, rig/clip requirements and a small minimum delivery, plus a short friends-playtest checklist. Do not add progression, purchases, horses or a new mode.

## Checks defined before building

1. Empty art slots start and play with greyboxes. Synthetic model imports mount without changing source instances; missing models, missing weapon Handle and embedded scripts are rejected. Cosmetic art cannot change bullet blocking or spawn clearance.
2. Desktop and phone controls produce one accepted shot per press; reload progress starts only on server acceptance and clears on completion, unequip, death and round end. Phone Fire/Reload buttons leave jump/movement space.
3. Existing arena and combat suites pass; rerun the two-player match lifecycle and real client input path, with readiness checks before scripted input.
4. First-shot/first-reload events log once per player per round in Studio. Runtime sources match files, test artefacts are removed and standard tuning is restored.
5. Art checklist explicitly separates the minimum playtest pack from later polish; no claim of public-launch readiness before real art, physical devices, live server latency and live analytics checks.
