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

		disko ={
			url = "github:nix-community/disko/latest";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

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

