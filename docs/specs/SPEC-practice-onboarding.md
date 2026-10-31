# Practice before the shootout

2026-10-31. Des authorised the growth recommendations. This milestone delivers recommendation 1; Josh’s art, observed friends test, bounty experiment, phone feel and promotional assets follow the review gates in GROWTH-PLAN.md.

We believe first visitors will practise instead of leaving an empty server because targets and an equipped revolver give them something useful immediately. We'll know if four of five new testers hit a target and complete a reload without help within 30 seconds; at least three should choose another multiplayer round. These are proposed project targets, not Roblox benchmarks.

## Behaviour

- Waiting players spawn facing three practice targets, can fire/reload with the existing validated weapon, and see personal practice hits and a concise invitation to practise. Hits never award match score or damage players while waiting.
- Targets use labelled grey parts tagged NeedsArt, with a PracticeTarget model slot in AssetConfig. Sources are cloned; collision/aim targets remain server-owned.
- A second player triggers the existing Preparing path: cancel reloads, hide/disable targets, replace characters and reset ammo/score for Shootout. Intermission and Preparing remain unable to fire. Returning to Waiting restores targets and practice positioning without blocking recovery.
- Log WesternPracticeEntered, WesternPracticeFirstShot, WesternPracticeFirstHit and WesternPracticeFirstReload once per player per connection using the existing server analytics function. Match events remain separate; no new client remotes or saved data.

## Acceptance checks, defined before implementation

1. Solo waiting: equipped revolver, visible targets, correct prompt; server-confirmed hit increments personal count once, miss does not, score stays zero. Six shots empty the cylinder, reload refills, duplicate IDs/rate limits/invalid aim remain rejected.
2. Waiting with two test players held below a test-only minimum: shooting another player does no damage; valid target hits work; cover blocks hits.
3. Second player arriving with normal tuning: fresh characters, six rounds, zero scores, hidden/unqueryable targets, normal multiplayer damage. Inactive phases reject input; pending practice reload cannot complete in a match.
4. Existing arena and combat suites pass. End a shortened match/leave to verify Waiting recovery and targets return. Native client fire/reload path is checked separately from server integration calls.
5. Studio events occur once per player/connection. Standard tuning restored, temporary tests removed, sources compared, build passes; keep cloud publishing with Des.

Human review of this milestone precedes implementing the bounty experiment. Final Josh art and real tester/device results cannot be substituted with generated art or invented findings.
