{
	config, pkgs, lib, system,
	inputs, darwin-modules,
#	arch, hostname, pkgs, unstable, nur,
#	nixModules, nixHomeModules, homeManagerM,
#	darwinModules, darwinHomeModules, homebrewM,
#	npkgs,
	...
}:
let
	mas-apps = import darwin-modules.mas-apps {};
in
{
	services.nix-daemon.enable = true;
	security.pam.enableSudoTouchIdAuth = true;

	users.users.nathand = { name = "nathand"; home = "/Users/nathand"; };
	home-manager = {
		users.nathand = import ./nathand.nix;
#		users.nathand.nixpkgs = pkgs;
	};

	homebrew = {
		enable = true;
		onActivation = {
			autoUpdate = false;
			upgrade = false;
			cleanup = "zap";
		};
		global.brewfile = true;
		caskArgs.language = "en-GB";
		brews = [ ];
		casks = [
			"1password" "1password-cli"
			"firefox"
			"iina"
			"vlc"
			"rectangle"
		];
		masApps = { inherit (mas-apps)
			Twitter
			WireGuard

			# iOS apps don't workthrough mas at the moment
#			Tachimanga
#			Paperback
			;
		};
	};
}

