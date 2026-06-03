{
  description = "Personal configs built with nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homeManager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nur.url = "github:nix-community/NUR";

    nixpkgs-droid-compat.url = "github:nixos/nixpkgs/nixos-24.05";
    nixOnDroid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid-compat";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # Check pinned pkg versions with these resources
    # https://lazamar.co.uk/nix-versions
    # https://nixhub.io
  };

  outputs =
    inputs:
    let
      mkHosts = import ./nix/hosts/mkHosts.nix { inherit inputs; };

      # Systems supported
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        inputs.nixpkgs.lib.genAttrs allSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs { inherit system; };
          }
        );

    in
    mkHosts [
      {
        # R710
        hostname = "zwei";
        type = "nixos";
        system = "x86_64-linux";
        configPath = ./nix/hosts/NixOS/zwei;
        unfreePkgs = [
          "plexmediaserver"
          "unifi-controller"
          "mongodb-ce"
        ];
      }
      {
        # R410
        hostname = "vcu";
        type = "nixos";
        system = "x86_64-linux";
        configPath = ./nix/hosts/NixOS/vcu;
      }
      # whitefox R510
      {
        # Mac15,6
        hostname = "LHC";
        type = "darwin";
        system = "aarch64-darwin";
        configPath = ./nix/hosts/macOS/LHC;
        unfreePkgs = [
          "raycast"
          "vscode"
        ];
      }
      {
        hostname = "HTPC";
        type = "nixos";
        system = "x86_64-linux";
        configPath = ./nix/hosts/NixOS/htpc;
        unfreePkgs = [ "plex-desktop" ];
      }
      {
        hostname = "NOP6";
        type = "nixOnDroid";
        system = "aarch64-linux";
        configPath = ./nix/hosts/android/NOP6.nix;
      }
      {
        hostname = "s24u";
        type = "nixOnDroid";
        system = "aarch64-linux";
        configPath = ./nix/hosts/android/s24u.nix;
      }
      {
        hostname = "vm-x86";
        type = "nixos";
        system = "x86_64-linux";
        configPath = ./nix/hosts/NixOS/vm;
      }
      {
        hostname = "vm-arm";
        type = "nixos";
        system = "aarch64-linux";
        configPath = ./nix/hosts/NixOS/vm;
      }
      #{
      #
      #
      #	# Nix refs https://mynixos.com
      ## TODO: add README.md to relevant areas like each module, host, etc.
      #	# `defaults` options ref https://macos-defaults.com
      #])
    ]
    // {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                lua-language-server
                nil
                nixfmt-rfc-style
                rumdl # markdown formatter
                vscode-json-languageserver
              ]
              ++ (with pkgs.tree-sitter-grammars; [
                tree-sitter-bash
                tree-sitter-css
                # tree-sitter-ini # available in 26.05+
                tree-sitter-json
                tree-sitter-lua
                tree-sitter-markdown
                tree-sitter-nix
                tree-sitter-python
                tree-sitter-toml
              ]);
          };
        }
      );
    };
}
