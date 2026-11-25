# nix/langDevshells.nix
#
# Per-language dev shells, merged into the flake's `devShells`.
# `default` (for editing this repo) is defined in flake.nix, not here.
# Use from any project:   use flake ~/dotfiles#js   /   nix develop ~/dotfiles#rust
{ inputs }:

let
  inherit (inputs.nixpkgs) lib;

  # Kept here (not in flake.nix) since it's only used to build devShells.
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  mkDevShells =
    system:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
      unstable = import inputs.unstable { inherit system; };

      g = pkgs.tree-sitter-grammars;

      # Packages every shell gets.
      base = with pkgs; [
        git
        jq
        ripgrep
        fd
        unzip
      ];

      # mkShell wrapper: base ++ extras. Add a shellHook here if you want banners.
      mkShell = extra: pkgs.mkShell {
        packages = base ++ extra;
      };

      # grammars [ "rust" "toml" ] -> [ g.tree-sitter-rust g.tree-sitter-toml ]
      grammars = names: map (n: g."tree-sitter-${n}") names;
    in
    {
      js = mkShell (
        (with pkgs; [
          nodejs
          bun
          typescript-language-server
          vscode-langservers-extracted # eslint + css + html + json
          biome
          oxlint
          oxfmt
          prettier
          tailwindcss-language-server
          astro-language-server
          svelte-language-server
          vue-language-server
        ])
        ++ grammars [
          "typescript"
          "json"
          "css"
        ]
      );

      rust = mkShell (
        (with pkgs; [
          rustc
          cargo
          clippy
          rustfmt
          taplo
        ])
        ++ (with unstable; [ rust-analyzer ]) # newest RA; drop this line for stable
        ++ grammars [
          "rust"
          "toml"
        ]
      );

      python = mkShell (
        (with pkgs; [
          python313
          uv
          ruff
          pyright
        ])
        ++ [ pkgs.python3Packages.python-lsp-server ] # pylsp
        ++ grammars [ "python" ]
      );
    };
in
lib.genAttrs systems mkDevShells
