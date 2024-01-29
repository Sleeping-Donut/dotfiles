{ inputs }:
let
	{ nixpkgs nixpkgs-unstable nur home-manager nix-homebrew darwin nix-on-droid ... } = inputs;

	darwin-modules = import ./macOS/modules;
	darwin-home-modules = import ./macOS/home/modules;
	nix-modules = import ../modules;
	nix-home-modules = import ../modules/home;

	generateConfigurations = (systemType, configs):
		builtins.mapAttrs (hostname: info: let inherit (info) cfg arch; in
			hostname = if systemType == "darwin" then
				darwin.lib.darwinSystem {
					system = arch;
					modules = [
						import cfg {
							inherit hostname arch;
							inherit (inputs) nixpkgs nixpkgs-unstable nur home-manager;
							inherit (inputs) darwin nix-homebrew;
							inherit nix-modules nix-home-modules darwin-modules darwin-home-modules;
							homebrew-modules = inputs.nix-homebrew.darwin
						}
					];
				}
			else if systemType == "nixOnDroid" then
				nix-on-droid.lib.nixOnDroidConfiguration {
					modules = [
						import cfg {
							inherit hostname arch;
							inherit (inputs) nixpkgs nixpkgs-unstable nur home-manager;
							inherit (inputs) nix-on-droid;
							inherit nix-modules nix-home-modules;
						}
					];
				}
			else if systemType == "nixos" then
				nixpkgs.lib.nixosSystem {
					modules = [
						import cfg {
							inherit hostname arch;
							inherit (inputs) nixpkgs nixpkgs-unstable nur home-manager;
							inherit nix-modules nix-home-modules;
						}
					];
				}
			else if systemType == "linux" then
				home-manager.lib.homeManagerConfiguration {
				pkgs = nixpkgs.legacyPackages."${arch}";
					modules = [
						import cfg {
							inherit hostname arch;
							inherit (inputs) nixpkgs nixpkgs-unstable nur home-manager;
							inherit nix-modules nix-home-modules;
						}
					];
				}
			else
				throw "Invalid system type";
		) configs;
in
{
	nixosConfigurations = generateConfigurations "nixos" {};

	linuxConfigurations = generateConfigurations "linux" {};

	darwinConfigurations = generateConfigurations "darwin" {
		X68000 = { arch = "aarch64-darwin"; cfg = ./macOS/X68000.nix; };
		LHC = { arch = "x86_64-darwin"; cfg = ./macOS/LHC.nix; };
	};

	nixOnDroidConfigurations = generateConfigurations "nixOnDroid" {};
}
