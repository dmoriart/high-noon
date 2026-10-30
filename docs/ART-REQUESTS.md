# Art requests — proposed Western shootout

2026-10-30: Josh to review the visual direction before final assets are made.

For the proposed first arena: an original frontier street kit (saloon frontage, sheriff frontage and cover), a revolver model, cowboy outfit and reload/fire animations. These are a proposal for milestone 2, not assets already commissioned or implemented. Use grey tagged parts until Josh's art is ready; record every imported asset and its creator in docs/ASSETS.md.

Portfolio capture once playable: street-level wide shot, over-cover gunfight, then close-up revolver reload; record the same view before and after Josh's art is installed. Add animation hooks when the playable weapon is implemented.

## Implemented prototype hooks

The runtime HUD exposes `PlayerGui.HighNoonHUD.WeaponPresentation`, a BindableEvent (a local animation notification). It fires `Fire` with the shooter Player for every replicated shot and `Reload` with the local Player when the server accepts a reload. Josh can attach firing, recoil, reload and sound presentation here; the server still decides damage and reload completion. Final weapon sounds and animations are pending Josh's work.

The grey camera revolver now follows the player's view and kicks when the server accepts a shot. Replace its shape definitions through AssetConfig; a polished rigged weapon will need a separate integration pass. Suggested capture: wide street shot; identical view with Josh's buildings; close-up firing and reload once animations are ready.

2026-10-30 reliability pass: the existing WeaponPresentation event now also fires `ReloadCancelled` with the local Player when switching weapons interrupts a reload. Use it to stop the reload animation; it does not require new art. The crosshair now lives under `PlayerGui.HighNoonAim.Crosshair` so it aligns with the camera independently of the HUD's safe-area margins.
