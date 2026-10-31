# First friends playtest

Target: a small desktop/phone test of one Western shootout. This is a test of the game, not a public-launch claim.

## Before inviting friends

- Des and Josh review `JOSH-FIRST-ART.md`; import each supplied Model/clip through AssetConfig and verify it in Play. Blank slots remain intentional greyboxes. Missing configured files must be fixed before publishing.
- Keep the original art files and `.rbxm` copies in source control, with creator/tools/date recorded in ASSETS.md.
- Play Solo: scene loads, controls are explained, waiting message is clear and the gun is equipped.
- Local two-player server: both spawn; shooting, cover, reload/interruption, death, respawn, victory, timeout and a second round work. Check Output for game errors and the analytics step logs.
- Test on a physical phone: movement/look, Fire, Reload and Jump remain reachable; one tap fires one round; reload progress clears correctly. Test a physical controller if it will be offered to this group.
- Publish the reviewed build to the intended private Roblox place and grant the testers play access. Confirm the real imported animations/audio have permission in a published server. Keep existing purchase systems out of the default build.

## Ten-minute session

1. Start with at least two testers. Begin with an empty-server practice visit, then join the second player. Give only: “Move, aim, fire, reload; first to ten eliminations wins.”
2. Watch whether each tester hits a practice target and reloads within 30 seconds without extra instructions.
3. Finish a round and see who remains for the next one. Ask what confused them and whether enemies were readable against the town.
4. Have one tester leave during a round, then return; confirm the remaining player can recover to waiting and a fresh match can start.
5. Save a few short gameplay clips for Josh, especially his gun and cover props from real player angles.

## Measure and decide

- First accepted shot: `WesternFirstShot`, once per player per match.
- First completed reload: `WesternFirstReload`, once per player per match.
- Existing `WesternMatchJoined`, `WesternMatchCompleted`, `WesternSecondMatchJoined` measure session progression. Studio prints events; live analytics delivery still requires a published-server check.
- Initial target: four of five testers fire and reload without help, and at least half stay for another round. Remaining connected is a retention proxy; observe whether they actually participate.

Write the result and one next decision in DECISIONS.md. Do not add progression or monetisation to solve basic control or readability problems.

Use TESTER-NOTES.csv for anonymous T1–T5 observations and PHONE-PLAYTEST.md for actual phone aiming. The ordered next steps and review gates are in GROWTH-PLAN.md. Leave rows blank until a real tester plays.
