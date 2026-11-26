---
name: git-commit
description: Use when committing code changes or writing commit messages.
---

# Git commit guidelines

Write the **why**, not the what. The diff shows what changed; the message says why it exists.

## Commit in logical blocks

- One idea per commit (feature, fix, refactor, migration, docs).
- Group by theme/layer, not chronology: core → providers → api → services → frontend → tooling → docs.
- Each commit leaves the tree working.
- If everything is staged at once: `git restore --staged .`, then `git add <paths>` per group, commit each.

## Message

```
<imperative summary>

<why — rationale or context not visible in the diff>
```

- Subject: imperative (`Add`, `Fix`, `Refactor`, `Migrate`, `Document`), ≤ ~50 chars.
- Body: 2–5 sentences, only the "why".
- Optional area prefix: `core:`, `server:`, `frontend:`, `docs:`.

## Assistance

Add the AI assistance trailer when the user or the codebase asks for it:

```
Assisted-By: LLM
```

Treat the codebase as asking when `AGENTS.md`/`CLAUDE.md` or recent commits carry it. Otherwise
commit without the trailer.

## Test

If you can't explain why in one sentence, you haven't figured it out yet — figure it out, then write that.
