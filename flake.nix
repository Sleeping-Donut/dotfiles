# 
# Nix flake config
# WIP
# README for guide
#
#  flake.nix *             
#   ├─ ./hosts
#   │   └─ default.nix
#   ├─ ./darwin
#   │   └─ default.nix
#   └─ ./nix
#       └─ default.nix
#

{
	description = "Personal configs using nix flakes";

	inputs =																# All flake references used to build. - The dependencies
	{
		nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";					# Default Stable Nix Packages
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";		# Unstable Nix Packages

		home-manager = {													# Nix home-manager to manage user environment
			url = "github:nix-community/home-manager/release-23.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		darwin = {															# MacOS management
			url = "github:lnl7/nix-darwin/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nur = {																# Nix User Repository
			url = "github:nix-community/NUR";
		};

		nix-on-droid = {													# Nix on android stuff
			url = "github:t184256/nix-on-droid/release-23.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

		# Ref github:MatthiasBenaets/nixos-config/flake.nix
		# nixgl for OpenGL stuff
		# hyprland
		# plasma-manager
	};

	outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, darwin, nur, nix-on-droid, nix-homebrew, ... }:		# Fn to tell flake what to do with the dependencies
		let																	# Variables taht can be used in the conifgs
			user = "nathand";
			location = "$HOME/.setup";	# Hmmmm......
		in
		{
			nixosConfigurations = (											# NixOS Host Configs
				import ./nix/nixos {
					inherit (nixpkgs) lib;
					inherit inputs nixpkgs nixpkgs-unstable home-manager nur user location;# hyperland etc...
				}
			);

			linuxConfigurations = (											# Linux Host Configs
				import ./nix/linux {
					inherit (nixpkgs) lib;
					inherit inputs nixpkgs nixpkgs-unstable home-manager user nur;
				}
			);

			darwinConfigurations = (										# macOS Host Configs
				import ./nix/darwin {
					inherit (nixpkgs) lib;
					inherit inputs nixpkgs nixpkgs-unstable home-manager darwin user nur nix-homebrew;
				}
			);

			nixOnDroidConfigurations = (									# nix-on-droid Host Configs
				import ./nix/android {
					inherit (nixpkgs) lib;
					inherit inputs nixpkgs nixpkgs-unstable home-manager nix-on-droid user nur;
				}
			);
		};
}
