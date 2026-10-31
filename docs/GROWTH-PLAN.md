# From prototype to a game friends return to

2026-10-31. Des approved all six recommendations. Work through the stages in order, with a human review after each tested implementation. No popularity claim is implied by completing this plan.

| Stage | Work | Evidence before advancing |
| --- | --- | --- |
| 1. Empty-server experience | Waiting-room target practice, safe firing/reloading, personal feedback and onboarding events | SPEC-practice-onboarding acceptance checks and Des/Josh review |
| 2. Josh’s weapon pack | Josh makes the revolver, Fire/Reload clips and shared crate/barrel palette in JOSH-FIRST-ART.md; Des imports and records provenance | First-person framing, opponent view, reload interruption and published-asset permissions checked together; Josh approves the result |
| 3. Observe five testers | Use FRIENDS-PLAYTEST.md and TESTER-NOTES.csv; watch before coaching | Four of five hit a target and reload within 30 seconds without help; at least three voluntarily play another round. Record failures as findings, not exceptions to hide |
| 4. Test one Western hook | Try a bounty marker on the unique match leader after the earlier stages are reviewed | Compare replay choices and leader complaints against the baseline; keep/remove after observation |
| 5. Phone aiming and fairness | Physical-phone movement/look/fire together, reachability, sensitivity and mouse-opponent sessions | PHONE-PLAYTEST.md passes with real observations; change one input variable at a time |
| 6. Honest packaging | Josh’s icon/thumbnail art and short actual-gameplay clip, following PROMO-BRIEF.md | Visuals reflect the playable build; publish only after Des reviews them |

## Measurement

Current match events cover joins, completions and second-match joins. Practice adds entered/first-shot/first-hit/first-completed-reload once per player per connection. Studio logs validate triggers; published-server delivery must be checked in Creator Analytics. Retention and session length should come from Roblox’s built-in dashboard, not duplicate telemetry. A second match joined is a proxy: observe whether that player participates.

Five testers reveal usability problems; they cannot establish a dependable retention rate or prove market demand. After obvious problems are fixed, invite a larger group and examine next-day return, match completion, device differences and acquisition sources. Keep a dated decision in DECISIONS.md with the evidence and the next smallest change. No ads, purchases or progression are required for the first test.

## Proposed bounty experiment, for later review

A unique leader with at least one elimination receives a visible WANTED marker during Shootout. Ties, waiting and intermission show no bounty. The marker provides a shared rival; it does not change damage, award Robux/currency, reveal through walls or change match scoring. Server score chooses the leader; death/leave/tie/round end update or remove the marker. Josh designs the marker/poster after the prototype is reviewed.

Hypothesis: players will pursue the leader and choose another round because the chase creates a memorable shared story. Proposed decision target: in a comparable five-tester session, at least three voluntarily replay and no more than one describes being leader as unfair; review this qualitative evidence against the baseline. Choose measurable bounty events only when the experiment is built; do not invent pursuit from a player’s location alone. Do not introduce a hidden bonus or call the experiment successful before testing it.

## Review responsibilities

Des: review implementation, arrange testers and publish the reviewed place. Josh: make/approve final art and capture portfolio footage. AI: implement the approved milestone, verify it, prepare test material and state remaining gaps. Human art, physical-device sessions and tester feedback cannot be fabricated by automation.
