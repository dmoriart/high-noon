# High Noon — Western multiplayer shooter proposal

Date: 2026-10-30
Status: Des requested implementation of the first Western game on 2026-10-30; milestone 2 implemented for review and Studio validation.

## Direction

An original cowboy multiplayer shooter inspired by the atmosphere of cinematic Westerns: dusty streets, timber buildings, frontier clothing and deliberate gunfights. Red Dead Redemption is a mood reference; use original names, maps, characters, music and art.

We believe Roblox shooter players will play a second Western shootout because deliberate gunplay and a readable frontier arena make each encounter satisfying. We'll know if at least 50% of participants in a ten-player playtest voluntarily play a second match.

## Milestone 1: identity and inherited-project audit

- Choose the game title and rename the GitHub fork and Rojo project.
- Replace the repository introduction with the new direction while preserving upstream credits and GPL licence.
- Record missing Studio dependencies and the proposed gameplay milestone.
- Leave inherited gameplay untouched until its baseline can be tested.

Acceptance checks: repository URL and project title agree; project JSON parses and all mapped source paths exist; licence and upstream credits remain; changes contain no new assets or purchases.

This milestone changes project identity and documentation only. Gameplay analytics begin with milestone 2, when a match loop exists to measure.

## Milestone 2: first playable shootout

Proposed scope: one small greybox frontier street, two-player free-for-all, one revolver, respawn, a visible score and a clear match result. Des requested building this Western foundation on 2026-10-30. Retain first-person controls initially; third-person aiming is a separate product choice.

1. Recover or replace required Studio dependencies and verify the inherited baseline.
2. Audit server validation for firing, damage and respawns before adapting the weapon.
3. Implement the smallest shootout using feature config for tuning and `src/shared/Config/AssetConfig.luau` for art references.
4. Use grey `PLACEHOLDER_<Thing>` parts tagged `NeedsArt` for missing art.
5. Record server-side AnalyticsService events for match joined, match completed and second match joined, once per player per match; no extra personal data.
6. Run Play Solo and a two-player local server: join, fire, damage, death, respawn, score, result, replay and leaving mid-match. Check server output for errors.

Do not expand into horses, open-world missions, progression or purchases during this milestone. Inherited cases and shop systems require a separate review before publication.

## Known baseline dependencies

- `src/replicatedfirst/BeginningSequence/init.client.lua` waits for `LoadingGUI`, `Intro` and `Workspace.Map`; the repository does not include the corresponding full scene and interface.
- `src/server/FrameworkScript.server.lua` expects `ServerStorage.Stored.MapIDs` and includes teleports to configured places. New Roblox places and ownership must be established before testing travel.
- Asset folders under `src/shared/Assets` include metadata; this is not proof that all required models, animations and interfaces are supplied.
- The inherited source was built and playtested; it fails on missing UI/save modules and outdated avatar constraints. The default Western runtime replaces those entry points; the full upstream mapping remains in evostrike.project.json.

## Implemented scope

Default project mapping runs a self-contained Western prototype. Original Evostrike files remain preserved; walking/jump tuning and the damage/falloff approach are reused. This does not claim the full Source movement controller is ported. The original weapon remotes accepted client hit information, so new damage uses server raycasts with state, ammo, range, rate, origin and request ID validation.

Players wait for at least two gunslingers, prepare fresh characters, play a three-minute or ten-elimination round, see a result and restart after ten seconds. Preparation has a timeout and retries from waiting. Leaving below two players ends the match. Equal positive scores produce a draw; all-zero scores produce no winner. Respawns take three seconds with two seconds of protection, lost on firing. Revolvers have unlimited reserve ammunition to keep this first playtest focused on combat.

Live analytics events: WesternMatchJoined, WesternMatchCompleted, WesternSecondMatchJoined. Studio logs the same event names without sending live analytics. These measure session retention into a second round, not confirmed player attention. No persistence or purchases are added.
