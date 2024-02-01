{ inputs }:
let
#	{ pkgs, unstable, nur, homeManager, homebrew, darwin, nixOnDroid, ... } = inputs;
	inherit (inputs) pkgs unstable nur homeManager homebrew darwin nixOnDroid;

	darwinModules = import ./macOS/modules;
	darwinHomeModules = import ./macOS/home/modules;
	nixModules = import ../modules;
	nixHomeModules = import ../modules/home;

	generateConfigurations = (systemType: configs:
		builtins.mapAttrs (hostname: info:
		let
			inherit (info) cfg arch; 
		in
			if systemType == "darwin" then
				let
				in
				darwin.lib.darwinSystem {
					system = arch;
					modules = [
					homeManager.darwinModules.home-manager
					./macOS/X68000

#						import ./macOS/X68000 {
#							inherit hostname arch pkgs unstable nur;
#							inherit nixModules nixHomeModules;
#							inherit darwin darwinModules darwinHomeModules;
#							homebrew = homebrew.darwin;
#							homeManager = homeManager.darwinModules.home-manager;
#						}
					];
				}
#			else if systemType == "nixOnDroid" then
#				nixOnDroid.lib.nixOnDroidConfiguration {
#					modules = [
#						import cfg {
#							inherit hostname arch;
#							inherit (inputs) pkgs unstable nur homeManager;
#							inherit (inputs) nixOnDroid;
#							inherit nixModules nixHomeModules;
#						}
#					];
#				}
#			else if systemType == "nixos" then
#				pkgs.lib.nixosSystem {
#					modules = [
#						import cfg {
#							inherit hostname arch;
#							inherit (inputs) pkgs unstable nur homeManager;
#							inherit nixModules nixHomeModules;
#						}
#					];
#				}
#			else if systemType == "linux" then
#				homeManager.lib.homeManagerConfiguration {
#					pkgs = pkgs.legacyPackages."${arch}";
#					modules = [
#						import cfg {
#							inherit hostname arch;
#							inherit (inputs) pkgs unstable nur homeManager;
#							inherit nixModules nixHomeModules;
#						}
#					];
#				}
			else
				throw "Invalid system type"
		) configs
	);
in
{
#	nixosConfigurations = generateConfigurations "nixos" {};

#	linuxConfigurations = generateConfigurations "linux" {};

	darwinConfigurations = generateConfigurations "darwin" {
#		X68000 = { arch = "x86_64-darwin"; cfg = ./macOS/X68000; };
		LHC = { arch = "aarch64-darwin"; cfg = ./macOS/LHC; };
	};

#	nixOnDroidConfigurations = generateConfigurations "nixOnDroid" {};
}
