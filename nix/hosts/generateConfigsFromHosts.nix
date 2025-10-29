{ inputs }:
let
	inherit (inputs) nixpkgs unstable nixpkgs-droid-compat nur homeManager nix-homebrew darwin nixOnDroid nix-flatpak disko;

	own-pkgs = import ../pkgs;
	overrides = import ../overrides;
	nix-modules = import ../modules;
	nixos-modules = import ../modules/nixos;
	home-modules = import ../modules/home;
	darwin-modules = import ../modules/darwin;
	darwin-home-modules = import ../modules/darwin/home;

	repo-root = ../..;

	genSources = (host: let
		unfreePkgs = host.unfreePkgs or [];
		unfreeFilter = (src: pkg: builtins.elem (src.lib.getName pkg) unfreePkgs);
		mkPkgs = pkgsIn: import pkgsIn {
			inherit (host) system;
			overlays = [];
			config.allowUnfreePredicate = unfreeFilter pkgsIn;
		};
		pkgs = mkPkgs nixpkgs;
		pkgs-unstable = mkPkgs unstable;
		pkgs-droid-compat = mkPkgs nixpkgs-droid-compat;

		pkgs-nur = import nur { pkgs = null; nurpks = pkgs-unstable; };

		flatpak = nix-flatpak.nixosModules.nix-flatpak;
		flatpak-home = nix-flatpak.homeManagerModules.nix-flatpak;
	in {
		inherit pkgs pkgs-unstable pkgs-droid-compat pkgs-nur flatpak flatpak-home;
	});

	genNixosConfig = (hostDetails: sources:
		nixpkgs.lib.nixosSystem {
			inherit (hostDetails) system;
			specialArgs = {
				inherit inputs repo-root own-pkgs overrides nix-modules nixos-modules home-modules disko;
				inherit (hostDetails) system hostname;
				inherit (sources) pkgs-unstable pkgs-nur nur flatpak;
			};
			modules = [
				{ nixpkgs.pkgs = sources.pkgs; }
				nix-modules.nix
				hostDetails.configPath
				homeManager.nixosModules.home-manager {
					home-manager.extraSpecialArgs = {
						inherit inputs repo-root own-pkgs overrides nix-modules home-modules;
						inherit (hostDetails) system;
						inherit (sources) pkgs-unstable pkgs-nur flatpak-home;
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
				inherit inputs repo-root own-pkgs overrides nix-modules home-modules;
				inherit (hostDetails) system;
				inherit (sources) pkgs-unstable pkgs-nur flatpak-home;
			};
			modules = [
				{ nixpkgs.pkgs = sources.pkgs; }
				nix-modules.nix
				hostDetails.configPath
			];
		}
	);
	genDarwinConfig = (hostDetails: sources:
		darwin.lib.darwinSystem {
			inherit (hostDetails) system;
			specialArgs = {
				inherit inputs repo-root own-pkgs overrides nur nix-modules darwin-modules;
				inherit (hostDetails) system hostname;
				inherit (sources) pkgs-unstable pkgs-nur;
			};
			modules = [
				{ nixpkgs.pkgs = sources.pkgs; }
				hostDetails.configPath
				darwin-modules.nix
				homeManager.darwinModules.home-manager {
					home-manager.extraSpecialArgs = {
						inherit inputs repo-root own-pkgs overrides nur nix-modules home-modules;
						inherit darwin-modules darwin-home-modules;
						inherit (hostDetails) system;
						inherit (sources) pkgs-unstable pkgs-nur;
					};
				}
			];
		}
	);
	genNixOnDroidConfig = (hostDetails: sources:
		nixOnDroid.lib.nixOnDroidConfiguration {
			pkgs = sources.pkgs-droid-compat;
			extraSpecialArgs = {
				inherit inputs repo-root nur nix-modules home-modules;
				inherit (hostDetails) hostname system;
				inherit (sources) pkgs-unstable pkgs-droid-compat pkgs-nur;
			};
			modules = let
				nix-settings = import nix-modules.nix {};
			in [
				{ nix = nix-settings.settings; }
				hostDetails.configPath
			];
		}
	);
	genDiyConfig = (hostDetails: sources:
		hostDetails.configPath {
			inherit inputs repo-root own-pkgs overrides nix-modules home-modules darwin-modules;
			inherit (hostDetails) hostname system;
			inherit (sources) pkgs pkgs-unstable pkgs-droid-compat pkgs-nur flatpak flatpak-home;
		}
	);
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

