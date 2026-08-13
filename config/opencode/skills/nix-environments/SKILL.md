---
name: nix-environments
description: Use when installing or running software, needing packages or tools, or creating environments. Covers nix run, nix shell, nix develop, and the never-install-globally rule.
---

# nix environments

Software comes from nix, never global installs. Everything below is user-local, reproducible, and leaves no host state.

## Choosing a command

| Need | Command |
|---|---|
| Run a tool once | `nix run nixpkgs#<pkg>` — e.g. `nix run nixpkgs#jq` |
| One-off env, run a command | `nix shell nixpkgs#<pkg>... -c <cmd>` — e.g. `nix shell nixpkgs#ripgrep nixpkgs#python311 -c "rg --version && python3 --version"` |
| Interactive one-off shell | `nix shell nixpkgs#<pkg>...` |
| Project work | `nix develop` (run inside the repo; uses its `flake.nix`) |

## Rules

- Never `npm i -g`, `brew install`, `cargo install`, `pip --user`, `gem install`, `go install`, `sudo ... install`. These mutate the host and aren't reproducible.
- `nix run` / `nix shell` are ephemeral — nothing persists, nothing to clean up.
- For a project, prefer `nix develop`: same benefits as run/shell, but the environment is committed in the flake, so it's reproducible and tracked per project.
- If the needed package isn't in nixpkgs, ask the user before any host-wide install.
