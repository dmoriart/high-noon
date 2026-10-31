# Josh's first art pack

Aim: give a small friends playtest a recognisable weapon and a few strong Western details. Finish one item, check it in the real camera, then start the next. The current town can stay as a blockout during this first playtest.

## Make these first, in order

| Priority | Delivery | What counts as done |
| --- | --- | --- |
| 1 | **One original six-shooter revolver** | Readable from behind in first person and held by another player; a wooden grip, metal frame, barrel and six-chamber cylinder. Save the source and an imported Roblox Model named `Revolver`. |
| 2 | **Fire and reload animation clips for that revolver** | Hammer/cylinder motions plus the existing procedural kick; fire fits inside 0.5 seconds, reload lasts 2.4 seconds, and stopping a reload returns cleanly to the idle pose. No root motion or ammunition/damage logic in the animation. |
| 3 | **A cover kit: one wooden crate and one barrel** | Both look good repeated around the street and match the collision dimensions below. Export Models named `Crate` and `Barrel`. |

That is the minimum visual pack for a friends test: one weapon, two animation clips and two reusable props. A crate and barrel share a wood/metal material palette, so make them together. Suggested starting targets, not Roblox platform limits: around 2,000 triangles for the revolver, 500 for the crate and 800 for the barrel; spend detail where the player actually sees it.

## Exact handoff for the first pack

### Revolver

- Model name: `Revolver`. Include a BasePart or MeshPart named **Handle** at the grip, and set it as the Model's PrimaryPart.
- Treat **-Z as forward** (barrel direction), **Y as up**. Put the Model pivot at the Handle/grip origin. Start near the current blockout's size: roughly 1.5 studs along the barrel direction, with a grip around 0.8 studs tall; check camera framing before final textures.
- Keep cylinder, hammer and trigger separate if they move. Connect moving pieces with Motor6Ds, or use an imported skinned rig. Static unconnected pieces are welded to Handle by the runtime; authored joints are kept.
- For a Motor6D rig, put an AnimationController at the Model's top level. The code can create its Animator. Animate the movable pieces; the game already supplies whole-weapon camera recoil.
- Supply `Fire` and `Reload` animation IDs published under an account/group permitted to use them in this experience. The first-person player model supports these clips; separate third-person hand/body animations are later polish.
- Keep the editable `.blend` source, textures, `.fbx` export and imported `.rbxm` Model. Include no Scripts or LocalScripts in the art Model.

### Crate and barrel

| Model name | Width × height × depth | Pivot | Orientation |
| --- | --- | --- | --- |
| `Crate` | 6 × 4 × 5 studs | Bottom centre, ground at Y=0 | Y up; -Z front |
| `Barrel` | 2.3 × 3 × 2.3 studs | Bottom centre, ground at Y=0 | Y up |

The models are cosmetic; invisible greybox shapes keep collision and bullet cover consistent. Stay inside those dimensions so a player cannot see through cover that still blocks shots, or see solid art where bullets pass through.

## Then create the environment kit

Priority 4 is **one reusable storefront kit**, not four unrelated buildings. Use it for the sheriff, general store and livery; the runtime supplies their signs. Add a taller saloon variant afterward.

| Slot / suggested Model | Width × height × depth | Required opening |
| --- | --- | --- |
| `Storefront16` | 24 × 16 × 24 studs | Centred front doorway, 6 studs wide and at least 9 high |
| `Saloon20` | 24 × 20 × 24 studs | Same doorway |

Pivot at the ground-level centre of the footprint, Y up, front toward -Z. Leave a clear front sign area 22 studs wide and 3 high at the top of the building height; the game keeps its sign boards/lettering. Porch posts, plank textures and window trim are good reusable pieces. Match the existing tested building footprint and doorway; the cosmetic model does not replace collision.

Priority 5 is a water-tower/wagon/fence polish pass, then a cowboy hat/outfit, UI decoration and richer character animations. These are not needed to begin the first friends test.

## How Des adds a completed item

1. Import into Studio and make a single Model with the name above. Verify size, pivot and forward direction against the blockout. Keep source models under `ReplicatedStorage.Art`; mark artist-owned sources `JoshArt`.
2. Save a `.rbxm` copy into `src/shared/Art/` so the model is included in future Rojo builds. This folder preserves unknown Studio imports during sync, but an unsaved import is not a repository backup.
3. Set the corresponding name in `src/shared/Config/AssetConfig.luau`, for example `Models.Revolver = "Revolver"`, `Models.Crate = "Crate"`, and `Models.Barrel = "Barrel"`. Blank names keep the blockouts; a nonblank missing/invalid Model produces a clear error.
4. Set `Animations.Fire` and `Animations.Reload` to the uploaded IDs. Optional `Sounds.Fire`, `Sounds.Reload` and `Sounds.Hit` accept original or properly licensed audio IDs; these slots are silent while blank.
5. Start Play and check first-person framing, another player's view, fire, reload, interruption, death/respawn and a second round. Verify actual animation/audio permission in a published private server before calling the delivery integrated.
6. Add a provenance line to `docs/ASSETS.md`: name, Josh, tools, date and any third-party source/licence. The game clones source art; it does not rewrite Josh's original models.

## Portfolio capture

For the revolver: the old grey gun, the finished gun in the same camera position, then firing/reloading with one interrupted reload. For the cover kit: a clean model turntable and a street shot showing it in use. For the town: camera (0, 7, 58) looking toward (0, 8, -35), before and after the storefront kit.
