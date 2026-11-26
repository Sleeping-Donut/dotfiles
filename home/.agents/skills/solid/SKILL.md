---
name: solid
description: Use when writing or reviewing SolidJS/SolidStart code — components, signals, stores, effects, routing, and UI. Covers the libraries and config this user prefers.
---

# SolidJS

Preference order for Solid work. Check `package.json` first — if the project already made a choice, follow it.

## Check shipped skills

Before writing Solid infrastructure, look for skills shipped inside `node_modules` (`node_modules/*/skills`, `node_modules/@*/*/skills`, any `SKILL.md`). Solid packages ship guidance for their own APIs; read and follow it rather than reinventing the pattern.

## Diagnostics

Enable `diagnostics: true` in the Vite config so Solid's compiler warnings and errors surface in the console. Leave it on while developing.

## UI components

1. **Themeable, unstyled components** — lean toward [Terracotta](https://github.com/lxsmnsyc/terracotta), or a similar system, so components stay easy to restyle for theming.
2. **Behaviour primitives** — [`@ui-sdk/core`](https://www.npmjs.com/package/@ui-sdk/core) for headless behaviour and [`@ui-sdk/solid`](https://www.npmjs.com/package/@ui-sdk/solid) for its Solid bindings. Build robust behaviour patterns (focus management, keyboard interaction, state machines) on these rather than hand-rolled equivalents.
3. **Other primitives/helpers** — [solid-primitives](https://primitives.solidjs.community/) before writing a custom signal/effect helper.
