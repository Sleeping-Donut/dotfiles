---
name: fd-find
description: Use when running fd or find in the bash tool to locate files by name, type, or extension. For regular file lookup use the built-in glob tool instead, not this skill.
---

# Find files: fd first, find fallback

This only applies when **locating files from the bash tool**. For regular file lookup, use the built-in `glob` tool instead — it already handles patterns and output formatting.

Prefer `fd`. Use `find` only when `fd` is unavailable.

## fd

- Always pass `--color=never` when output may be captured or piped, to avoid ANSI escapes in results.
- `fd [pattern] [path]` — recursive by default, respects `.gitignore`.
- `-t f` files only, `-t d` directories only, `-e py`/`-e ts` by extension.
- `-H` include hidden files, `-I` ignore `.gitignore`, `-L` follow symlinks, `-d <n>` max depth.
- Useful flags: `-x <cmd>` run a command per result, `-g '<glob>'` glob mode, `--changed-within` for recently modified.

## find (fallback)

- `find . -name 'pattern' -not -path '*/node_modules/*' -print`
- `-type f` files only, `-type d` dirs only, `-iname` case-insensitive, `-maxdepth <n>` limit depth.
- Pipe through `sort` when you want deterministic ordering.
