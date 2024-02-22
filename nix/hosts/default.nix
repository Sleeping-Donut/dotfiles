{ inputs }:
let
#	{ pkgs, unstable, nur, homeManager, homebrew, darwin, nixOnDroid, ... } = inputs;
	inherit (inputs) nixpkgs unstable nur homeManager nix-homebrew darwin nixOnDroid;

	darwinModules = import ./macOS/modules;
	darwinHomeModules = import ./macOS/home/modules;
	nixModules = import ../modules;
	nixHomeModules = import ../modules/home;
	my-modules = {
		nix = import ../modules;
		home = import ../modules/home;
		darwin = import ../modules/darwin;
		darwin-home = import ../modules/darwin/home;
#		nixOS = import ../modules/nixOS;
	};

	generateConfigurations = (systemType: configs:
		builtins.mapAttrs (hostname: info:
		let
			inherit (info) configPath system;
			pkgs = nixpkgs.legacyPackages.${system};
			pkgs-unstable = unstable.legacyPackages.${system};
		in
			# nix-darwin default configuration layer
			if systemType == "darwin" then
				darwin.lib.darwinSystem {
					inherit system;
#					services.nix-daemon.enable = true;
#					security.pam.enableSudoTouchIdAuth = true;
					specialArgs = { inherit pkgs pkgs-unstable inputs my-modules; };
					modules = [
						configPath
						homeManager.darwinModules.home-manager {
							home-manager = {
								useGlobalPkgs = true;
								useUserPackages = true;
								extraSpecialArgs = { inherit pkgs pkgs-unstable; };
							};
						}
					];
				}
#			else if systemType == "nixOnDroid" then
#				nixOnDroid.lib.nixOnDroidConfiguration {
#					modules = [
#						import configPath {
#							inherit hostname system;
#							inherit (inputs) pkgs unstable nur homeManager;
#							inherit (inputs) nixOnDroid;
#							inherit nixModules nixHomeModules;
#						}
#					];
#				}
#			else if systemType == "nixos" then
#				pkgs.lib.nixosSystem {
#					modules = [
#						import configPath {
#							inherit hostname system;
#							inherit (inputs) pkgs unstable nur homeManager;
#							inherit nixModules nixHomeModules;
#						}
#					];
#				}
#			else if systemType == "linux" then
#				homeManager.lib.homeManagerConfiguration {
#					pkgs = pkgs.legacyPackages."${system}";
#					modules = [
#						import configPath {
#							inherit hostname system;
#							inherit (inputs) pkgs unstable nur homeManager;
#							inherit nixModules nixHomeModules;
#						}
#					];
#				}
#			else if systemType == "diy" then
#				# Something to let you just have a configuration.nix somewhere like a normal one
#				configPath { inherit hostname system inputs my-modules; }
			else
				throw "Invalid system type"
		) configs
	);
in
{
#	nixosConfigurations = generateConfigurations "nixos" {};

#	linuxConfigurations = generateConfigurations "linux" {};

	darwinConfigurations = generateConfigurations "darwin" {
#		X68000 = { system = "x86_64-darwin"; configPath = ./macOS/X68000; };
		LHC = { system = "aarch64-darwin"; configPath = ./macOS/LHC; };
	};

#	nixOnDroidConfigurations = generateConfigurations "nixOnDroid" {};
}
