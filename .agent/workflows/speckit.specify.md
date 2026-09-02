---
name: speckit.specify
description: Turn a feature request into specs/NNN-slug/spec.md using .specify/templates/spec-template.md. Run this before any planning or implementation work on a new feature. Delegates the actual writing to the spec-writer subagent.
---

# speckit.specify

1. Confirm `.specify/memory/constitution.md` has no unfilled placeholders — if
   it does, run `speckit.constitution` first.
2. Determine the next feature number (`NNN` — zero-padded, one more than the
   highest existing `specs/` directory) and a short kebab-case slug from the
   request.
3. Delegate to the **spec-writer** subagent: create `specs/{{NNN}}-{{slug}}/`
   and write `spec.md` from `.specify/templates/spec-template.md`, filling in
   problem, user stories, and acceptance criteria from the request. Leave
   genuinely unclear points in "Open questions" rather than guessing — that's
   what `speckit.clarify` is for.
4. Set `spec.md`'s status to `draft`.
5. If `spec.md` has any open questions, tell the human and suggest running
   `speckit.clarify` before moving to `speckit.planning` — a plan written
   against an ambiguous spec just moves the ambiguity downstream where it's
   more expensive to fix.
6. If there are no open questions, the spec can move straight to `clarified` or
   `approved` per the human's call, and `speckit.planning` can start.
