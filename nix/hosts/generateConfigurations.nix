{ inputs }:
{
	generateConfigurations = let
		inherit (inputs) nixpkgs unstable nur homeManager nix-homebrew darwin nixOnDroid nix-flatpak;
		# NOTE: nur has a whole rigmarole so look it up to set it up

		nix-modules = import ../modules {};
		home-modules = import ../modules/home {};
		darwin-modules = import ../modules/darwin {};
		darwin-home-modules = import ../modules/darwin/home {};
		
		applyConfigToHosts = (definitionBlock: configs: let
			mapHosts = builtins.mapAttrs (hostname: info: let
				inherit (info) configPath system;
				unfreePkgs = if builtins.hasAttr "unfreePkgs" info then info.unfreePkgs else [];

				unfreeFilter = src: pkg: builtins.elem (src.lib.getName pkg) unfreePkgs;

				sources = {
					pkgs = import nixpkgs { inherit system;
						overlays = [];
						config.allowUnfreePredicate = unfreeFilter nixpkgs;
					};
					pkgs-unstable = import unstable { inherit system;
						overlays = [];
						config.allowUnfreePredicate = unfreeFilter unstable;
					};
					pkgs-nur = import nur { pkgs = null; nurpks = pkgs-unstable; };

					flatpak = nix-flatpak.nixosModules.nix-flatpak;
					flatpak-home = nix-flatpak.homeManagerModules.nix-flatpak;
				};
			in
				definitionBlock sources
			);
		in
			mapHosts configs
		);

		darwinConfigs = applyConfigToHosts (sources:
			darwin.lib.darwinSystem {
				inherit system;
				specialArgs = {
					inherit inputs system hostname nur nix-modules darwin-modules;
					inherit (sources) pkgs pkgs-unstable pkgs-nur;
				};
				modules = [
					configPath
					nix-modules.nix
					homeManager.darwinModules.home-manager {
						home-manager = {
							extraSpecialArgs = {
								inherit inputs system nur nix-modules home-modules;
								inherit (sources) pkgs pkgs-unstable pkgs-nur;
								inherit darwin-modules darwin-home-modules;
							};
						};
					}
				];
			}
		);
		home = applyConfigToHosts (sources:
			homeManager.lib.homeManagerConfiguration {
				inherit system;
				extraSpecialArgs = {
					inherit inputs system nur nix-modules home-modules flatpak-home;
					inherit (sources) pkgs pkgs-unstable pkgs-nur;
				};
				modules = [
					configPath
				];
			}
		);
		nixos = applyConfigToHosts (sources:
			pkgs.lib.nixosSystem {
				inherit system;
				specialArgs = {
					inherit inputs system hostname nur nix-modules flatpak;
					inherit (sources) pkgs pkgs-unstable pkgs-nur;
				};
				modules = [
					configPath
					homeManager.nixosModules.home-manager {
						extraSpecialArgs = {
							inherit inputs system pkgs pkgs-unstable nix-modules home-modules flatpak-home;
							inherit (sources) pkgs pkgs-unstable pkgs-nur;
							# inherit nixos-modules;
						};
					}
				];
			}
		);
		nixOnDroid = applyConfigToHosts (sources:
			nixOnDroid.lib.nixOnDroidConfiguration {
				inherit system;
				specialArgs = {
					inherit inputs system hostname nur nix-modules home-modules;
					inherit (sources) pkgs pkgs-unstable pkgs-nur;
				};
				modules = [
					configPath
				];
			}
		);
		diy = applyConfigToHosts (sources:
			configPath {
				inherit inputs hostname system nur;
				inherit (sources) pkgs pkgs-unstable pkgs-nur;
			}
		);
	in {
		inherit home nixos darwin nixOnDroid diy;
	};
}
