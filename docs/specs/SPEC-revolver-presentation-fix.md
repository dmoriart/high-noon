# Imported revolver size and firing audio

2026-10-31. Des reports the imported gun is too small and silent. We believe players will read the weapon and its firing more clearly with a correctly scaled first-person model and the supplied gunshot; verify with Studio framing and a server-accepted shot creating a loaded, playing clip. Human sound/size preference remains the final review.

The imported StarterPack.Revolver is only ~0.4 studs long and has separate unintegrated combat scripts. Preserve that original unchanged under ServerStorage.ImportedArtSources.Revolver; mount a visual-only copy through AssetConfig and retain the existing validated combat system. Export the visual model to the repository, record its unconfirmed creator, scale only runtime clones, and hide the local held copy to avoid a second overlapping gun. Use the imported Gunshot ID; do not invent a replacement sound or change damage/tuning.

Checks: original part dimensions and scripts unchanged; runtime camera/world scale and single visible gun; one configured sound with nonzero duration loads/starts after accepted firing; ordinary ammo/reload still work; asset/build/syntax and source comparisons pass. Des must still verify sound permission in a published server and actual perceived volume/framing.
