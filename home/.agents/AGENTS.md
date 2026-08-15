# Global rules

## Software & environments

- Never install globally: no `npm i -g`, `brew install`, `cargo install`, `gem install`, `pip install --user`, `go install`, or `sudo ... install`.
- Use nix instead, preferring the most ephemeral option:
  - `nix run nixpkgs#<pkg>` — run a tool once, nothing installed.
  - `nix shell nixpkgs#<pkg>...` — quick one-off environment.
  - `nix develop` — project work (env tracked in the repo's flake).
- If something isn't available via nix, ask before touching the host.

## Search

- Prefer `rg` over `grep`; fall back to `grep` only when `rg` is missing.
