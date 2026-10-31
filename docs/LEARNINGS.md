# High Noon learnings

- 2026-10-30: The inherited source-only place stopped on missing UI and save modules; a Studio playtest exposed the gaps. Keep the original source preserved and build a self-contained Western entry point before reusing dependent systems.
- 2026-10-30: A font enum recalled from memory did not exist; Play failed immediately. Check runtime enums and start Play after adding UI or scene code.
- 2026-10-30: A server command's require used separate module state from the running scripts; an integration test falsely reported inactive combat. Run integration checks from a normal server Script in Play.
- 2026-10-30: Health regeneration and deferred Humanoid.Died delivery caused false test failures. Compare damage against current health and allow the death event to dispatch before checking counters.
- 2026-10-30: The HUD's top-bar inset put the crosshair 29 pixels away from the camera ray; measured in a live client. Keep aim markers in a viewport-aligned layer and verify the physical pixel position after resizing.
- 2026-10-30: Unequipping and re-equipping during a reload still refilled ammo; a scripted swap reproduced it. Cancel on Unequipped, disconnect the listener, and require delayed completion to match that exact reload request.
- 2026-10-30: A temporary town preview survived a Studio reopen/publish, which would trip the runtime's duplicate-arena check. Mark generated previews explicitly, replace only tagged greybox parts at startup, and refuse replacement if protected or unrecognised art was added.

- 2026-10-30: Playtesting found mouse-tool activation unreliable and touch Fire overlapping Jump. Bind mouse firing explicitly with GUI/chat guards and a shared debounce; check accepted server ammo changes, and position touch buttons after Roblox creates them. A tool reporting input success is not proof that the game received it.

- 2026-10-31: The first practice playtest spawned the player back at an old location after PivotTo; Roblox’s later spawn placement overrode it. Move the existing SpawnLocations for Waiting and restore them before loading match characters; verify the final position in a real client.
- 2026-10-31: Des reported a tiny silent imported revolver; inspection found a 0.4-stud StarterPack tool outside the art slot and a blank runtime Fire sound. Integrate visual copies through AssetConfig, check import units, use relative camera scaling, and verify the configured shot sound instead of assuming an imported Tool is the active game weapon.
