---
name: speckit.planning
description: Turn a clarified/approved spec.md into plan.md using .specify/templates/plan-template.md, including the constitution check. Run after speckit.clarify (or directly after speckit.specify if there were no open questions), before speckit.tasks.
---

# speckit.planning

1. Confirm `spec.md` status is `clarified` or `approved` and has no unresolved
   "Open questions" — if it does, route to `speckit.clarify` first instead of
   planning around an ambiguity.
2. Delegate to the **spec-writer** subagent: write `plan.md` from
   `.specify/templates/plan-template.md` in the same `specs/NNN-slug/`
   directory — approach, components/files touched, data model changes (or
   "none"), risks.
3. Fill in the "Constitution check" checklist for real, against the actual
   plan — don't tick boxes reflexively. If a principle would be violated,
   that's a risk to surface, not something to silently work around; flag it to
   the human before implementation starts, and note in "Risks" what changes if
   the constitution wins vs. if an exception is granted.
4. Set `plan.md`'s status to `draft`, then `approved` once the human (or the
   orchestrator, if the human has delegated that) signs off.
5. Hand back: ready for `speckit.tasks`.
