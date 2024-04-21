{ inputs }:
let
	inherit (inputs) nixpkgs unstable nur homeManager nix-homebrew darwin nixOnDroid nix-flatpak;

	nix-modules = import ../modules {};
	home-modules = import ../modules/home {};
	darwin-modules = import ../modules/darwin {};
	darwin-home-modules = import ../modules/darwin/home {};

	genNixosConfig = (hostDetails: sources:
		nixpkgs.lib.nixosSystem {
			inherit (hostDetails) system;
			specialArgs = {
				inherit inputs nix-modules;
				inherit (hostDetails) system hostname;
				inherit (sources) pkgs pkgs-unstable pkgs-nur nur flatpak;
			};
			modules = [
				hostDetails.configPath
				homeManager.nixosModules.home-manager {
					home-manager.extraSpecialArgs = {
						inherit inputs nix-modules home-modules;
						inherit (hostDetails) system;
						inherit (sources) pkgs pkgs-unstable pkgs-nur flatpak-home;
						# inherit nixos-modules;
					};
				}
			];
		}
	);
	genHomeConfig = (hostDetails: sources:
		homeManager.lib.homeManagerConfiguration {
			inherit (hostDetails) system;
			home-manager.extraSpecialArgs = {
				inherit inputs nix-modules home-modules;
				inherit (hostDetails) system;
				inherit (sources) pkgs pkgs-unstable pkgs-nur flatpak-home;
			};
			modules = [
				hostDetails.configPath
			];
		}
	);
	genDarwinConfig = (hostDetails: sources:
		darwin.lib.darwinSystem {
			inherit (hostDetails) system;
			specialArgs = {
				inherit inputs nur nix-modules darwin-modules;
				inherit (hostDetails) system hostname;
				inherit (sources) pkgs pkgs-unstable pkgs-nur;
			};
			modules = [
				hostDetails.configPath
				nix-modules.nix
				homeManager.darwinModules.home-manager {
					home-manager.extraSpecialArgs = {
						inherit inputs nur nix-modules home-modules;
						inherit darwin-modules darwin-home-modules;
						inherit (hostDetails) system;
						inherit (sources) pkgs pkgs-unstable pkgs-nur;
					};
				}
			];
		}
	);
	genNixOnDroidConfig = (hostDetails: sources:
		nixOnDroid.lib.nixOnDroidConfiguration {
			inherit (hostDetails) system;
			extraSpecialArgs = {
				inherit inputs nur nix-modules home-modules;
				inherit (hostDetails) hostname system;
				inherit (sources) pkgs pkgs-unstable pkgs-nur;
			};
			modules = [
				hostDetails.configPath
			];
		}
	);
	genDiyConfig = (hostDetails: sources:
		hostDetails.configPath {
			inherit inputs;
			inherit (hostDetails) hostname system;
			inherit (sources) pkgs pkgs-unstable pkgs-nur flatpak flatpak-home;
		}
	);
	genSources = (host: let
		unfreePkgs = host.unfreePkgs or [];
		unfreeFilter = (src: pkg: builtins.elem (src.lib.getName pkg) unfreePkgs);
		pkgs = import nixpkgs { inherit (host) system;
			overlays = [];
			config.allowUnfreePredicate = unfreeFilter nixpkgs;
		};
		pkgs-unstable = import unstable { inherit (host) system;
			overlays = [];
			config.allowUnfreePredicate = unfreeFilter unstable;
		};
		pkgs-nur = import nur { pkgs = null; nurpks = pkgs-unstable; };

		flatpak = nix-flatpak.nixosModules.nix-flatpak;
		flatpak-home = nix-flatpak.homeManagerModules.nix-flatpak;
	in { inherit pkgs pkgs-unstable pkgs-nur flatpak flatpak-home;
	});
	genConfigsForHostType = (type: generator: hosts: let
		filteredHosts = builtins.filter (host: host.type == type) hosts;
		transformedHostList = builtins.map (host:
			{ name = host.hostname; value = generator host (genSources host); }
		) filteredHosts;
	in
		builtins.listToAttrs transformedHostList
	);
in
(hosts: let
	genConfigsForHostTypeBareWrapped = (type: generator: let
		wrapped = genConfigsForHostType type generator hosts;
		bare = genConfigsForHostType (type+"-diy") genDiyConfig hosts;
	in
		wrapped // bare
	);
in {
		nixosConfigurations = genConfigsForHostTypeBareWrapped "nixos" genNixosConfig;
		homeConfigurations = genConfigsForHostTypeBareWrapped "home" genHomeConfig;
		darwinConfigurations = genConfigsForHostTypeBareWrapped "darwin" genDarwinConfig;
		nixOnDroidConfigurations = genConfigsForHostTypeBareWrapped "nixOnDroid" genNixOnDroidConfig;
})

