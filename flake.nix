#
# Nix flake config
# 
# README.md for guide
#

{
	description = "Personal config built with nix";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
		unstable.url = "github:nixos/nixpkgs/nixos-unstable";

		darwin = {
			url = "github:lnl7/nix-darwin";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		homeManager = {
			url = "github:nix-community/home-manager/release-23.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nixos-hardware.url = "github:nixos/nixos-hardware";

		nur.url = "github:nix-community/NUR";

		nixOnDroid = {
			url = "github:t184256/nix-on-droid/release-23.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

	};

	outputs = inputs @ { ... }:
	let

		darwin-modules = import ./nix/macOS/modules;
		darwin-home-modules = import ./macOS/home/modules;
		nix-modules = import ../modules;
		nix-home-modules = import ../modules/home;
		hosts = import ./nix/hosts {
			inherit inputs;
#			inherit nix-modules nix-home-modules darwin-modules darwin-home-modules;
		};
	in
	{
		nixosConfigurations = hosts.nixosConfigurations;
		linuxConfigurations = hosts.linuxConfigurations;
		darwinConfigurations = hosts.darwinConfigurations;			# macOS hosts
		nixOnDroidConfigurations = hosts.nixOnDroidConfigurations;	# android configs using nix-on-droid

	};
}
