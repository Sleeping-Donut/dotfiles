---
name: js-tooling
description: Use when choosing JavaScript/TypeScript tooling — package managers (npm, pnpm, bun, yarn, vite+), linters, formatters, and bundlers (eslint, biome, oxlint, oxfmt, rolldown, prettier). Apply when installing, adding, or running any JS tool.
---

# JavaScript tooling preferences

Preference order for all JS/TS tooling decisions.

## Package managers

1. **Pre-existing project setup** — if the project already uses a tool (lockfile, `packageManager` field, `.npmrc`, config files), use that one. Don't switch it randomly.
2. **vite+ toolchain** — a bundler/toolchain that bundles together a bunch of tools (vite ecosystem).
3. **pnpm** — preferred normal package manager.
4. **bun** — acceptable; stability is trusted less than pnpm but preferred over regular npm.
5. **npm** — least favorite; use only when nothing above applies.
6. **yarn** — generally avoid.

## Build / lint / format tooling

1. **Pre-existing project setup** — use whatever the project already has configured.
2. **oxc-based tools** — rolldown (bundler), oxlint (linter), oxfmt (formatter).
3. **Alternatives** — eslint, biome, prettier, etc., only when oxc-based tooling doesn't fit.
