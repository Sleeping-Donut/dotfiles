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
			pkgs = nixpkgs.legacyPackages.${system};
			pkgs-unstable = unstable.legacyPackages.${system};
		in
			# nix-darwin default configuration layer
			if systemType == "darwin" then
				darwin.lib.darwinSystem {
					inherit system;
					specialArgs = { inherit inputs pkgs pkgs-unstable nix-modules darwin-modules; };
#					nix = {
#						gc = {											# garbage Collection
#							automatic = true;
#							interval.Day = 14;
#							options = "--delete-older-than 14d";
#						};
#						extraOptions = ''
#						auto-optimise-store = true
#						experimental-features = nix-command flakes
#						'';
#					};
					modules = [
						configPath
						nix-modules.nix
						homeManager.darwinModules.home-manager {
							home-manager = {
								extraSpecialArgs = { inherit home-modules darwin-home-modules; };
							};
						}
					];
				}
			else if systemType == "nixOnDroid" then
				nixOnDroid.lib.nixOnDroidConfiguration {
					inherit system;
					specialArgs = { inherit inputs pkgs pkgs-unstable nix-modules home-modules; };
					modules = [
						configPath
					];
				}
			else if systemType == "nixos" then
				pkgs.lib.nixosSystem {
					inherit system;
					specialArgs = { inherit inputs pkgs pkgs-unstable nix-modules; };
					modules = [
						configPath
						homeManager.nixosModules.home-manager {
							extraSpecialArgs = { inherit home-modules; };
						}
					];
				}
			else if systemType == "linux" then
				homeManager.lib.homeManagerConfiguration {
					inherit system;
					extraSpecialArgs = { inherit inputs pkgs pkgs-unstable home-modules; };
					modules = [
						configPath
					];
				}
			else if systemType == "diy" then
				# Something to let you just have a configuration.nix somewhere like a normal one
				configPath { inherit inputs hostname system pkgs pkgs-unstable; }
			else
				throw "Invalid system type"
		) configs
	);
in
{
	nixosConfigurations = generateConfigurations "nixos" {};

	linuxConfigurations = generateConfigurations "linux" {};

	darwinConfigurations = generateConfigurations "darwin" {
#		X68000 = { system = "x86_64-darwin"; configPath = ./macOS/X68000; };
		LHC = { system = "aarch64-darwin"; configPath = ./macOS/LHC; };
	};

	nixOnDroidConfigurations = generateConfigurations "nixOnDroid" {};
}
