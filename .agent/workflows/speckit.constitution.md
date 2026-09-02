---
name: speckit.constitution
description: Interview the human and fill in .specify/memory/constitution.md, or amend it later. Run this first on a new harness, before speckit.specify — every other workflow assumes a filled-in constitution, not a template full of {{PLACEHOLDER}} tokens.
---

# speckit.constitution

## First run (template still has placeholders)

1. Check `.specify/memory/constitution.md` for unfilled `{{PLACEHOLDER}}` tokens.
   If none, this harness already has a constitution — skip to "Amendment" below.
2. Ask the human for, or infer from the repo where possible:
   - 2-4 principles beyond "spec before code" (already filled in). Push for
     things that are actually load-bearing and specific to this project —
     "write clean code" is not a principle, "no synchronous DB calls in request
     handlers" is.
   - Stack (language/framework — infer from `package.json`/`pyproject.toml`/etc.
     if present rather than asking).
   - Testing requirement — be concrete ("unit test in the same PR" vs "some
     integration coverage eventually" are different commitments).
   - Forbidden patterns, if any.
   - Definition of done.
3. Write the filled-in file back to `.specify/memory/constitution.md`. Don't
   leave any `{{PLACEHOLDER}}` token in the delivered file — if something is
   genuinely undecided, write an explicit note ("TBD — needs a decision on X")
   rather than a silent placeholder that looks filled in but isn't.
4. Tell the human this is the one file worth reading in full before continuing.

## Amendment (constitution already filled in, but needs to change)

1. Don't hand-edit the file directly. Per its own amendment process, open a
   `specs/NNN-constitution-update/spec.md` (via `speckit.specify`) describing
   what's changing and why, get it approved, then edit the constitution as the
   implementation of that spec.
2. This applies even to small wording changes if they change the actual rule —
   use judgment for genuine typo fixes, but default to the spec path for
   anything a future reader would want the reasoning for.
