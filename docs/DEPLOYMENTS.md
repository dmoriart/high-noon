# High Noon deployments

## 2026-10-30 — prepared; Roblox publish pending

- Requested by Des: push to Roblox and commit.
- Gameplay commit: f262544936a43d126141b11203fc4db97384c714, pushed to `codex/western-foundation` on GitHub.
- Intended Roblox destination: High Noon, place 80590253472100, universe 10773807901. Studio reported existing place version 3 before the attempt.
- All ten Studio runtime source files matched the committed files before publishing. Temporary test scripts were absent and normal tuning was restored. Validation coverage and the incomplete lifecycle rerun are recorded in VALIDATION.md.
- Publish attempt: AssetService:SavePlaceAsync with the explicit destination and SaveWithoutPublish=false was rejected: "Game:SavePlace can only be called from a server script, aborting save function". No successful publish was confirmed.
- UI fallback could open the clean local build, but the computer-control surface remained attached to the Seven before the rain window. No publish command was issued against that other game.
- Remaining action: in the existing High Noon Studio window for place 80590253472100, use File → Publish. If using the local build instead, choose the existing High Noon destination when publishing. The prepared local build is `/Users/desmoriarty/OneDrive/Code/roblox/high-noon/High Noon.rbxlx`.

## 2026-10-31 — Crossfire published

- Des approved the revolver fixes and requested merge/publish.
- PR #3 merged into main at 3c5f4fbef2b803a5c1792b63d44fe7dc523e4e38.
- Verified all 13 runtime sources in Crossfire Studio match main; the imported visual revolver is present and the original Tool remains preserved in ServerStorage.ImportedArtSources.
- Published from File → Publish in the Crossfire Studio window for place 80590253472100. Studio explicitly confirmed: Published new changes in "Crossfire" to Roblox.
- Publishing did not change the audience/access settings. Live-server audio permissions and gameplay were not separately retested after publishing.
