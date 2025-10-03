# Nix configs

Influences:
- 
- https://gitlab.com/usmcamp0811/dotfiles
- https://nixos-and-flakes.thiscute.world

## TODO

- default devices/hosts for each platform of a minimal setup
- NOP6 config (Android)
- NPC config (Linux)
- zwei, vcu conifg (NixOS ?? Linux)

## Check Why a package is installed

Use `nix why-depends`

It takes 2 args: dependent, depedency

Each arg can be a drv or store path

To find the store path for a specific generation example:
`nix eval --raw PATH_TO_FLAKE#darwinConfigurations.HOSTNAME.system`

## NixOS

TBA...

## Nix (Linux)

### Install

1. Install nix
    - Multi-user (recommended) - `sh <(curl -L https://nixos.org/nix/install) --daemon`
    - Single user - `sh <(curl -L https://nixos.org/nix/install) --no-daemon`
3. Enable flakes by either:
    - cat to either config `experimental-features = nix-command flakes`
        - `/etc/nix/nix.conf`
        - `~/.config/nix/nix.conf`
    - add to any executed nix commands `--experimental-features 'nix-command flakes'`
2. run `nix run --flake path/to/flake#DEVICE`
    - 2.1 or is it `nix run nixpkgs#home-manager -- switch --flake path/to/flake#DEVICE`


## Darwin (macOS)

#### First time install

1. Install homebrew - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
2. Install Nix - `sh <(curl -L https://nixos.org/nix/install)`
3. run `nix build path/to/flake#darwinConfigurations.DEVICE.system` 
- 3.2 Enable flakes by either:
	- cat to either config `experimental-features = nix-command flakes`
        	- `/etc/nix/nix.conf`
        	- `~/.config/nix/nix.conf`
	- add to any executed nix commands `--experimental-features 'nix-command flakes'`
- 3.1 WRONG! -> run `nix run nix-darwin -- switch --flake path/to/flake#DEVICE`
4. run `./result/sw/bin/darwin-rebuild switch --flake path/to/flake#DEVICE`

#### Rerunning

1. run `darwin-rebuild switch -- flake path/to/flake#device`


## nix-on-droid (Android)

Use `nix-on-droid switch --flake path/to/flake#DEVICE` to build and activate your configuration (`path/to/flake#DEVICE` will expand to `.#nixOnDroidConfigurations.DEVICE`). If you run `nix-on-droid switch --flake path/to/flake`, the default configuration will be used.

Note: Currently, Nix-on-Droid can not be built with an pure flake build because of hardcoded store paths for proot. Therefore, every evaluation of a flake configuration will be executed with `--impure` flag. (This behaviour will be dropped as soon as the default setup does not require it anymore.)

