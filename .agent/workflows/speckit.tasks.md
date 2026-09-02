---
name: speckit.tasks
description: Break an approved plan.md into tasks.md using .specify/templates/tasks-template.md — ordered, dependency-aware, one coder-subagent turn per task. Run after speckit.planning, before speckit.implement.
---

# speckit.tasks

1. Confirm `plan.md` status is `approved` — don't generate tasks against a
   draft plan that might still change.
2. Delegate to the **spec-writer** subagent: write `tasks.md` from
   `.specify/templates/tasks-template.md` in the same `specs/NNN-slug/`
   directory. Break the plan's "Components / files touched" into small,
   ordered tasks:
   - Each task should be completable in one coder-subagent turn — if a task
     touches more than a handful of files or mixes unrelated concerns, split
     it.
   - Mark tasks `[P]` only if they truly share no file dependencies with other
     `[P]` tasks in the same batch — false parallelism causes merge conflicts
     between coder-subagent runs.
   - Add explicit `depends on: TNNN` notes for sequencing that isn't just
     top-to-bottom order.
3. Hand back to the orchestrator: ready for `speckit.implement`.
