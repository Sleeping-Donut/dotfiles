{ inputs }:
let
	inherit (inputs) nixpkgs unstable nur homeManager nix-homebrew darwin nixOnDroid;
	# NOTE: nur has a whole rigmarole so look it up to set it up

	nix-modules = import ../modules {};
	home-modules = import ../modules/home {};
	darwin-modules = import ../modules/darwin {};
	darwin-home-modules = import ../modules/darwin/home {};

	generateConfigurations = (systemType: configs:
		builtins.mapAttrs (hostname: info:
		let
			inherit (info) configPath system;

			# Move this somewhere appropriate
			unfreeFilter = src: pkg: builtins.elem (src.lib.getName pkg) [
				"raycast"
				"vscode"
			];

			pkgs = import nixpkgs { inherit system;
				overlays = [];
				config.allowUnfreePredicate = unfreeFilter nixpkgs;
			};
			pkgs-unstable = import unstable { inherit system;
				overlays = [];
				config.allowUnfreePredicate = unfreeFilter unstable;
			};
			pkgs-nur = import nur { pkgs = null; nurpks = pkgs-unstable; };
		in
			# nix-darwin default configuration layer
			if systemType == "darwin" then
				darwin.lib.darwinSystem {
					inherit system;
					specialArgs = { inherit inputs system hostname pkgs pkgs-unstable pkgs-nur nix-modules darwin-modules; };
					modules = [
						configPath
						nix-modules.nix
						homeManager.darwinModules.home-manager {
							home-manager = {
								extraSpecialArgs = {
									inherit inputs system pkgs pkgs-unstable pkgs-nur nix-modules home-modules;
									inherit darwin-modules darwin-home-modules;
								};
							};
						}
					];
				}
			else if systemType == "nixOnDroid" then
				nixOnDroid.lib.nixOnDroidConfiguration {
					inherit system;
					specialArgs = { inherit inputs system hostname pkgs pkgs-unstable nix-modules home-modules; };
					modules = [
						configPath
					];
				}
			else if systemType == "nixos" then
				pkgs.lib.nixosSystem {
					inherit system;
					specialArgs = { inherit inputs system hostname pkgs pkgs-unstable nix-modules; };
					modules = [
						configPath
						homeManager.nixosModules.home-manager {
							extraSpecialArgs = {
								inherit inputs system pkgs pkgs-unstable nix-modules home-modules;
#								inherit nixos-modules;
							};
						}
					];
				}
			else if systemType == "linux" then
				homeManager.lib.homeManagerConfiguration {
					inherit system;
					extraSpecialArgs = { inherit inputs system pkgs pkgs-unstable nix-modules home-modules; };
					modules = [
						configPath
					];
				}
			else if systemType == "diy" then
				# Something to let you just have a configuration.nix somewhere like a normal one
				configPath { inherit inputs hostname system pkgs pkgs-unstable nur; }
			else
				throw "Invalid system type"
		) configs
	);
in
{
	# Nix refs https://mynixos.com

	nixosConfigurations = generateConfigurations "nixos" {};

	linuxConfigurations = generateConfigurations "linux" {};

	# macOS Configs
	# `defaults` options ref https://macos-defaults.com
	darwinConfigurations = generateConfigurations "darwin" {
#		X68000 = { system = "x86_64-darwin"; configPath = ./macOS/X68000; };
		LHC = { system = "aarch64-darwin"; configPath = ./macOS/LHC; };
	};

	nixOnDroidConfigurations = generateConfigurations "nixOnDroid" {
		NOP6 = { system = "aarch46-linux"; configPath = ./android/NOP6.nix; };
	};

	diyConfigurations = generateConfigurations "diy" {};
}
