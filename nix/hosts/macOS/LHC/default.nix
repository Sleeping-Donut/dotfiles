{
	config, pkgs, lib, system, pkgs-unstable,
	inputs, darwin-modules, hostname,
#	arch, hostname, pkgs, unstable, nur,
	...
}:
let
	mas-apps = import darwin-modules.mas-apps {};
in
{
	services.nix-daemon.enable = true;
	security.pam.enableSudoTouchIdAuth = true;

	networking = { hostName = hostname; computerName = hostname; };
	fonts.fonts = with pkgs; [
		noto-fonts
#		noto-fonts-cjk
#		noto-fonts-extra
#		noto-fonts-emoji
	];

	environment.systemPackages = let
		stable = with pkgs; [];
		unstable = with pkgs-unstable; [];
	in
		stable ++ unstable;

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
			"mediamate"
			"rectangle"
			"vanilla"
			"visual-studio-code"
			"vlc"
			"zed"
		];
		masApps = { inherit (mas-apps)
			# Must first be logged in to App Store with account that has previously downloaded these applications
			Gifski
			Twitter
			WireGuard

			# iOS apps don't workthrough mas at the moment
#			Tachimanga
#			Paperback
			;
		};
	};
}

