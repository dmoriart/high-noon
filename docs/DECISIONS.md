# Decisions

- 2026-10-30: Adapt Evostrike into an original Western multiplayer shooter, as requested by Des. Begin with project identity and dependency discovery; propose one arena and one revolver before wider systems. Reconsider scope after the first multiplayer playtest and Des's review.
- 2026-10-30: Retain the upstream GPL-2.0 licence and author credits. Keep inherited art attribution distinct from Josh's future work.

- 2026-10-30: Des chose High Noon as the working title. Rename the GitHub repository to `high-noon` and the Rojo project to `High Noon`. Revisit the title if Des chooses a final release name.
- 2026-10-30: Des requested the Western game implementation. Use the prior one-arena/revolver milestone. The inherited baseline fails in Studio on missing dependencies and accepts client-reported hits, so the default build now runs a self-contained Western entry point with server raycasts. Preserve the original mapping as evostrike.project.json and all upstream files for future selective reuse; reuse its movement tuning and adapt its damage/falloff approach. Reconsider wider integration only when missing dependencies and validation are resolved.
