{
	description = "Personal configs built with nix";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
		unstable.url = "github:nixos/nixpkgs/nixos-unstable";

		darwin = {
			url = "github:lnl7/nix-darwin/nix-darwin-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		homeManager = {
			url = "github:nix-community/home-manager/release-25.05";
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

		nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

		# Nixpkgs that has transmission 4.0.5 as seen on https://lazamar.co.uk/nix-versions/?package=transmission&version=4.0.5&fullName=transmission-4.0.5&keyName=transmission_4&revision=0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb&channel=nixpkgs-unstable#instructions
		# pin because of bug (or you'll get banned)
		nixpkgs-transmission-safe.url = "github:NixOS/nixpkgs/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb";

		# Check pinned pkg versions with these resources
		# https://lazamar.co.uk/nix-versions
		# https://nixhub.io
	};

	outputs = inputs @ { ... }:
	let

		hosts = import ./nix/hosts {
			inherit inputs;
		};

		# Systems supported
		allSystems = [
			"x86_64-linux" # 64-bit Linux Intel/AMD
			"aarch64-linux" # 64-bit Linux ARM
			"x86_64-darwin" # 64-bit macOS Intel
			"aarch64-darwin" # 64-bit macOS ARM
		];
		forAllSystems = f: inputs.nixpkgs.lib.genAttrs allSystems (system: f {
			pkgs = import inputs.nixpkgs { inherit system; };
		});

	in
#	{
## TODO: change hosts.{type} to be nixos | home | darwin | nixOnDroid
#		nixosConfigurations = hosts.nixosConfigs;
#		linuxConfigurations = hosts.linuxConfigurations;
#		darwinConfigurations = hosts.darwinConfigurations;			# macOS hosts
#		nixOnDroidConfigurations = hosts.nixOnDroidConfigurations;	# android configs using nix-on-droid
#
#	};
	hosts // {
		devShells = forAllSystems ({ pkgs }: {
			default = pkgs.mkShell {
				packages = with pkgs; [
					lua-language-server
					nil
					nixfmt-rfc-style
				];
			};
		});
	};
}

