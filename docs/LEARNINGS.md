# High Noon learnings

- 2026-10-30: The inherited source-only place stopped on missing UI and save modules; a Studio playtest exposed the gaps. Keep the original source preserved and build a self-contained Western entry point before reusing dependent systems.
- 2026-10-30: A font enum recalled from memory did not exist; Play failed immediately. Check runtime enums and start Play after adding UI or scene code.
- 2026-10-30: A server command's require used separate module state from the running scripts; an integration test falsely reported inactive combat. Run integration checks from a normal server Script in Play.
- 2026-10-30: Health regeneration and deferred Humanoid.Died delivery caused false test failures. Compare damage against current health and allow the death event to dispatch before checking counters.
