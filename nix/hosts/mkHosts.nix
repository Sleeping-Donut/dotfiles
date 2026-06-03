{ inputs }:
let
	inherit (inputs) nixpkgs unstable nixpkgs-droid-compat nur homeManager nix-homebrew darwin nixOnDroid nix-flatpak disko;

	repo-root = ../..;
	own-pkgs = import ../pkgs;
	overrides = import ../overrides;

	modules = {
		common = import ../modules;
		nixos = import ../modules/nixos;
		home = import ../modules/home;
		darwin = import ../modules/darwin;
		darwin-home = import ../modules/darwin/home;
	};

	mkSources = host: let
		unfreePkgs = host.unfreePkgs or [];
		unfreeFilter = src: pkg: builtins.elem (src.lib.getName pkg) unfreePkgs;
		mkPkgs = pkgsIn: import pkgsIn {
			inherit (host) system;
			overlays = [];
			config.allowUnfreePredicate = unfreeFilter pkgsIn;
		};
		pkgs = mkPkgs nixpkgs;
		pkgs-unstable = mkPkgs unstable;
	in {
		inherit pkgs pkgs-unstable;
		pkgs-droid-compat = mkPkgs nixpkgs-droid-compat;
		pkgs-nur = import nur { pkgs = null; nurpks = pkgs-unstable; };
		flatpak = nix-flatpak.nixosModules.nix-flatpak;
		flatpak-home = nix-flatpak.homeManagerModules.nix-flatpak;
		inherit own-pkgs overrides disko;
	};

	mkArgs = host: sources: {
		inherit inputs sources modules repo-root;
		inherit (host) system hostname;
		inherit (sources) pkgs-unstable;
	};

	genNixosConfig = host: sources:
		nixpkgs.lib.nixosSystem {
			inherit (host) system;
			specialArgs = mkArgs host sources;
			modules = [
				{ nixpkgs.pkgs = sources.pkgs; }
				modules.common.nix
				host.configPath
				homeManager.nixosModules.home-manager {
					home-manager.extraSpecialArgs = mkArgs host sources;
				}
			];
		};

	genHomeConfig = host: sources:
		homeManager.lib.homeManagerConfiguration {
			inherit (host) system;
			home-manager.extraSpecialArgs = mkArgs host sources;
			modules = [
				{ nixpkgs.pkgs = sources.pkgs; }
				modules.common.nix
				host.configPath
			];
		};

	genDarwinConfig = host: sources:
		darwin.lib.darwinSystem {
			inherit (host) system;
			specialArgs = mkArgs host sources;
			modules = [
				{ nixpkgs.pkgs = sources.pkgs; }
				host.configPath
				modules.darwin.nix
				homeManager.darwinModules.home-manager {
					home-manager.extraSpecialArgs = mkArgs host sources;
				}
			];
		};

	genNixOnDroidConfig = host: sources:
		nixOnDroid.lib.nixOnDroidConfiguration {
			pkgs = sources.pkgs-droid-compat;
			extraSpecialArgs = mkArgs host sources;
			modules = [ host.configPath ];
		};

	configsOfType = type: generator: hosts: let
		filtered = builtins.filter (host: host.type == type) hosts;
		transformed = builtins.map (host:
			{ name = host.hostname; value = generator host (mkSources host); }
		) filtered;
	in
		builtins.listToAttrs transformed;
in
hosts: {
	nixosConfigurations = configsOfType "nixos" genNixosConfig hosts;
	homeConfigurations = configsOfType "home" genHomeConfig hosts;
	darwinConfigurations = configsOfType "darwin" genDarwinConfig hosts;
	nixOnDroidConfigurations = configsOfType "nixOnDroid" genNixOnDroidConfig hosts;
}

