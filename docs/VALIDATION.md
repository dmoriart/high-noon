# High Noon prototype validation

Date: 2026-10-30. Runtime testing used the High Noon Studio place (80590253472100); Seven before the rain was untouched.

## Passed

- Rojo 7.4.4 built both the self-contained Western project and the preserved upstream project mapping.
- Official Luau compiler parsed all new runtime and test modules. This is syntax compilation, not full Roblox type analysis.
- Studio sources were synced and compared byte for byte; source lengths and position-weighted checksums were also recorded. Normal tuning (180-second rounds, ten eliminations, ten-second intermissions) was restored after tests, and temporary test runners were removed.
- Play Solo: arena, waiting state, 100 health, six rounds, equipped revolver, camera viewmodel and HUD. A desktop screenshot was inspected for layout and weapon framing.
- Two-player local simulation: 20 combat integration assertions passed. These cover body/head damage, falloff, NaN/infinite input, unknown actions, spoofed origins, actual server-ray damage, burst rate limits, duplicate request IDs, weapon cooldown, reload start/completion, firing during reload, cover, spawn shields, equipped state, lethal damage, score/death counting, respawn and restored ammo.
- A second two-player simulation passed nine lifecycle assertions with Studio-only shortened tuning (12-second rounds, one elimination, three-second intermission). A real client sent the lethal shot through the game's RemoteEvent; score-limit victory, disabled combat after the result, next-round score/health/ammo reset, timer expiry, no false winner, player departure and return to waiting all passed.
- Studio output confirmed WesternMatchJoined, WesternMatchCompleted and WesternSecondMatchJoined events. Live AnalyticsService delivery was not tested.
- git diff --check passed. Upstream source and licence are preserved.

## How tests were run

`tests/Combat.spec.luau` is a module run from an ordinary server Script during a two-player Studio shootout. Requiring it from the plugin command environment uses separate module state and does not test the running combat system. Its result was `PASS 20`.

`tests/Match.spec.luau` runs from a server Script with `tests/ClientDriver.client.luau` temporarily mapped to StarterPlayerScripts and the shortened config above. StudioTestService launched the clients; the leaving client called LeaveTest. The result returned to the editor was `PASS 9 match lifecycle checks`. These test scripts are excluded from the default project, and the temporary Studio copies were removed.

## Limits and remaining review

This is a greybox prototype for Des and Josh to review. Mobile/gamepad controls, live server latency, larger player counts and live analytics need testing. Final art, sound and animations are pending. Progress is not persisted, and no purchases are present in the Western runtime.

Studio also logged localhost connection failures from the MCP plugin and an avatar asset-type warning for asset 203785492. They did not prevent the tests above; no new asset IDs were introduced by this prototype. Initial test harness failures (module cache isolation, health regeneration, deferred death events and client startup timing) were corrected before the passing runs.

The original Evostrike mapping still fails at runtime without its missing Studio dependencies; a successful upstream Rojo build is not a successful upstream playtest. The default Western runtime avoids those dependencies. No public release or cloud publish was performed.

## Reliability pass — 2026-10-30

Reproduced the crosshair/camera offset at a 58-pixel top-bar inset (29-pixel aim error), then verified zero-pixel error with the new aim layer at desktop viewport sizes 856×617 and 1140×617 and in the iPhone 14 landscape simulator at 749×388. Phone screenshots exposed the desktop HUD crowding the touch controls, prompting the compact layout.

Reproduced a partially empty cylinder refilling after an unequip/re-equip during a reload. The expanded two-player combat suite then returned `PASS 25 combat checks`, including immediate cancellation, keeping ammo unchanged, rejecting an old completion callback during a new reload and successfully completing a fresh reload. All prior combat assertions were retained.

The compact layout was checked visually in phone landscape: the large desktop panels disappear, health and ammo move above the touch controls, and a server score change is reflected in the title. Switching back to desktop restored the scoreboard, control legend and bottom vitals; aim remained at zero-pixel error. This is simulator layout coverage, not a complete physical-phone input test.

The additional match-lifecycle rerun could not be completed in this session. Studio first rejected a launch because a previous test was still in progress, then later launched sessions without the required clients/readiness. An attempted stronger controller-input harness also timed out and was not counted as a pass; its unverified changes were discarded. The existing nine-check lifecycle test is preserved, with its earlier passing run recorded above, but has not passed again after this reliability change. No result from the launcher was treated as game success.
