---
name: speckit.memory-sync
description: Run the memory depuration + promotion pass. Use after speckit.tasks/speckit.implement finish a feature, before marking it done, and optionally at the start of a long session to recover prior context.
---

# speckit.memory-sync

Keeps the flash memory layer (Engram) clean and promotes what's durable into the
persistent vault (Obsidian Second Brain). See
`references/memory-integration.md` in the sdd-multi-agent-harness skill for the
full model this workflow implements; this file is the runnable lifecycle step.

## When to run this

- **Start of session / after a context reset or compaction:** recovery mode —
  pull prior state back in, don't depurate yet.
- **After `speckit.tasks` completes implementation for a feature, before the
  feature is marked done:** full pass — depurate, then promote.

## Recovery mode (start of session)

1. Call the Engram context/search tool(s) for the current project to recover
   what was being worked on before this session started.
2. Surface a short summary to the orchestrator: what was in progress, what was
   already decided, what's still open. Don't re-derive this from scratch by
   re-reading the whole repo history if Engram already has it.
3. Hand back to the orchestrator to continue normally.

## Full pass (after implementation, before "done")

1. **Collect.** Pull the observations saved by spec-writer/coder/reviewer during
   this feature's work.
2. **Depurate.** Run Engram's comparison/judgment/review tools over that set:
   - Flag and resolve duplicates (two observations describing the same decision).
   - Flag and resolve contradictions (two observations that disagree — don't
     silently pick one; surface the conflict if it isn't obviously resolvable
     from context, and ask the orchestrator/human rather than guessing).
   - Mark stale or superseded observations accordingly rather than deleting them
     outright, unless the tool's own semantics call for deletion.
3. **Select for promotion.** From the reviewed, non-stale observations, pick the
   ones that are durable knowledge rather than task-scoped scratch:
   - Architecture or design decisions and their rationale.
   - Naming/convention choices that should generalize beyond this feature.
   - Root-cause findings for bugs that could recur.
   - Anything that arguably belongs in the constitution but isn't there yet —
     flag this explicitly to the human instead of silently editing the
     constitution.
   Leave everything else (in-progress state, dead ends, task-scoped notes) in
   Engram only.
4. **Promote.** For each selected item, write it into the Obsidian vault using
   the vault's save/capture command, with enough context that it's findable and
   makes sense read cold (not just "fixed the bug" — what was the bug, why did
   it happen, what's the fix).
5. **Report.** Tell the orchestrator/human, briefly: how many observations were
   reviewed, how many conflicts were found and how they were resolved, and what
   got promoted to the vault (by title, not full content).

## Boundaries

- This workflow does not write application code and does not edit specs/plans —
  it only touches memory (Engram) and the vault (Obsidian).
- If Engram or the Obsidian vault isn't configured/reachable, skip gracefully and
  say so rather than blocking the rest of the SDD lifecycle on it — the memory
  layer is an enhancement to the harness, not a hard dependency of it.
