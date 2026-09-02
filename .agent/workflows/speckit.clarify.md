---
name: speckit.clarify
description: Resolve the "Open questions" section of a spec.md before a plan gets written against it. Run after speckit.specify if the spec has open questions, or any time a plan/implementation surfaces an ambiguity the spec should have settled.
---

# speckit.clarify

1. Read the target `specs/NNN-slug/spec.md`'s "Open questions" section (or the
   new ambiguity just surfaced, if this was triggered mid-plan/mid-implement
   rather than right after `speckit.specify`).
2. For each question:
   - If it's answerable from context already in the conversation or repo,
     answer it and update the spec directly (acceptance criteria, out-of-scope,
     or user stories, whichever section it actually belongs in) — don't leave
     it sitting in "Open questions" once it's answered.
   - If it genuinely needs the human's input (a product/business decision, a
     tradeoff with no obviously-correct answer), ask — batch multiple open
     questions into one round rather than going back and forth per-question.
3. Once every open question is resolved, update `spec.md`'s status to
   `clarified` and remove the now-empty "Open questions" section content (or
   leave it explicitly empty — don't delete the heading, future passes look
   for it).
4. Hand back to the orchestrator: the spec is ready for `speckit.planning`.
