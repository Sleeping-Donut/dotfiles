#
# Nix flake config
# 
# README.md for guide
#

{
	description = "Personal config built with nix";
	inputs = {
		pkgs.url = "github:nixos/nixpkgs/nixos-23.05";
		unstable.url = "github:nixos/nixpkgs/nixos-unstable";

		darwin = {
			url = "github:lnl7/nix-darwin";
			inputs.nixpkgs.follows = "pkgs";
		};

		homeManager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "unstable";
		};

		nixos-hardware.url = "github:nixos/nixos-hardware";

		nur.url = "github:nix-community/NUR";

		nixOnDroid = {
			url = "github:t184256/nix-on-droid/release-23.05";
			inputs.nixpkgs.follows = "pkgs";
		};

		nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

	};

	outputs = inputs @ { ... }:
	let
		hosts = import ./nix/hosts { inherit inputs; };
	in
	{
		nixosConfigurations = hosts.nixosConfigurations;
		linuxConfigurations = hosts.linuxConfigurations;
		darwinConfigurations = hosts.darwinConfigurations;			# macOS hosts
		nixOnDroidConfigurations = hosts.nixOnDroidConfigurations;	# android configs using nix-on-droid

	};
}
