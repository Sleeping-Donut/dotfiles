{ inputs }:
let
	inherit (inputs) nixpkgs unstable nur homeManager nix-homebrew darwin nixOnDroid nix-flatpak;
	# NOTE: nur has a whole rigmarole so look it up to set it up

	generateConfigsFromHosts = import ./generateConfigsFromHosts.nix { inherit inputs; };
in
	generateConfigsFromHosts ([
#		Type: "nixos" | "home" | "darwin" | "nixOnDroid" | "nixos-diy" | "home-diy" | "darwin-diy" | "nixOnDroid-diy"

		{ # R710
			hostname = "zwei"; type = "nixos"; system = "x86_64-linux"; configPath = ./NixOS/zwei;
			unfreePkgs = [ "plexmediaserver" "unifi-controller" "mongodb-ce" ];
		}
		{ # R410
			hostname = "vcu"; type = "nixos"; system = "x86_64-linux"; configPath = ./NixOS/vcu;
		}
		# whitefox R510
		{ # Mac15,6
			hostname = "LHC"; type = "darwin"; system = "aarch64-darwin"; configPath = ./macOS/LHC;
			unfreePkgs = [ "raycast" "vscode" ];
		}
		{
			hostname = "HTPC"; type ="nixos"; system = "x86_64-linux"; configPath = ./NixOS/htpc;
			unfreePkgs = [ "plex-desktop" ];
		}
		{ hostname = "NOP6"; type = "nixOnDroid"; system = "aarch46-linux"; configPath = ./android/NOP6.nix; }
		{ hostname = "s24u"; type = "nixOnDroid"; system = "aarch46-linux"; configPath = ./android/s24u.nix; }
		{ hostname = "vm-x86"; type = "nixos"; system = "x86_64-linux"; configPath = ./NixOS/vm; }
		{ hostname = "vm-arm"; type = "nixos"; system = "aarch64-linux"; configPath = ./NixOS/vm; }
#{
#
#
#	# Nix refs https://mynixos.com
## TODO: add README.md to relevant areas like each module, host, etc.
#	# `defaults` options ref https://macos-defaults.com
])
