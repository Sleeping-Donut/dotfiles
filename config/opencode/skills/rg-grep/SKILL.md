---
name: rg-grep
description: Use when running rg or grep in the bash tool to search file contents or command output. For regular codebase searches use the built-in grep tool instead, not this skill.
---

# Search: rg first, grep fallback

This only applies when **searching file contents from the bash tool**. For regular codebase searching, use the built-in `grep` tool instead — it already uses ripgrep and handles color, gitignore, and output formatting.

Prefer `rg`. Use `grep` only when `rg` is unavailable.

## ripgrep (rg)

- Always pass `--color=never` when output may be captured or piped, to avoid ANSI escapes in results.
- `rg -n 'pattern' [path]` — line numbers (the norm).
- Respects `.gitignore` by default; `rg -uu` to search everything.
- Useful flags: `-i` case-insensitive, `-w` whole word, `-C 3` context, `-l` files only, `-c` counts, `--files` list files, `-g '!node_modules'` glob filter, `-t py`/`-t js` language filter.

## grep (fallback)

- `grep -rn --color=never -E 'pattern' --exclude-dir={.git,node_modules,target,dist,.next} .`
- Always pass `--color=never`; add `-E` for extended regex, `-i` case-insensitive, `-l` files only.
