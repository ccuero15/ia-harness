---
name: speckit.implement
description: Work through tasks.md — dispatch each task (or parallel [P] batch) to the coder subagent, check the handback, send to the reviewer, then move on. Run after speckit.tasks. If the memory layer is installed, speckit.memory-sync's full pass runs after this workflow finishes a feature, before it's marked done.
---

# speckit.implement

The orchestrator drives this loop; it never edits code itself.

1. Read `tasks.md` for the feature. Take the next unchecked task (or the next
   batch of `[P]` tasks with no shared file dependencies).
2. Dispatch to the **coder** subagent with: the task text, the relevant section
   of `plan.md`, and a pointer to the constitution. One task (or one
   no-shared-files `[P]` batch) per dispatch — don't hand over the whole task
   list at once.
3. On handback, check for the three things the coder is required to report:
   what changed, tests added/updated and their result, any deviation from the
   plan. If any is missing, send it back rather than marking the task done on
   an incomplete handback.
4. Dispatch the same change to the **reviewer** subagent against the plan's
   constitution-check items and the spec's acceptance criteria. The reviewer
   flags gaps; it does not fix them. If it flags something, that's a new small
   task (or a reopened one) for the coder — don't let the orchestrator
   "helpfully" patch it in directly.
5. Once the reviewer is satisfied, tick the task in `tasks.md` and move to the
   next one.
6. When every task is ticked and the reviewer has signed off on the full diff
   against the spec's acceptance criteria: if the memory layer is present, run
   `speckit.memory-sync`'s full pass (depuration + promotion) before telling
   the human the feature is done. If it isn't present, just report done.
