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
			# Try move some of these to nixpkgs (need to have them show up in ~/Applications
			"1password" "1password-cli"
			"firefox"
			"iina"
			"vlc"
			"rectangle"
			"visual-studio-code"
			"zed"
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

