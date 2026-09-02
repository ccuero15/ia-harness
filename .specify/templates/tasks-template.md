# Tasks: {{FEATURE_NAME}}

**Plan:** `specs/{{NNN}}-{{feature-slug}}/plan.md`

Ordered, dependency-aware, each one small enough for a single coder-subagent turn.
The orchestrator assigns these one at a time (or in parallel batches when a
`[P]` marks tasks with no shared file dependencies).

- [ ] T001 {{task description}} — files: {{path/to/file}}
- [ ] T002 [P] {{task description}} — files: {{path/to/file}}
- [ ] T003 {{task description}} — depends on: T001

## Handback protocol

Each task, when picked up by a coder subagent, must come back with:
1. What changed (files + summary)
2. Tests added/updated and their result
3. Any deviation from the plan, and why

The orchestrator reviews this before marking the task done and dispatching the next one.
