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
	fonts.packages = with pkgs; [
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
		brews = [
			"ata"
		];
		casks = [
			# Try move some of these to nixpkgs (need to have them show up in ~/Applications
			"1password" "1password-cli"
			"aegisub"
			"alacritty"
			"balenaetcher"
			"blender"
			"discord"
			"firefox"
			"fork"
			"gramps"
			"iina"
			"jordanbaird-ice"
			"mediamate"
			"mrkai77/cask/loop"
			"mullvadvpn"
			"pocket-casts"
			"raycast"
			"rectangle"
			"tailscale"
			"telegram"
			"transmission"
			"utm"
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
			MicrosoftRemoteDesktop

			# iOS apps don't work through mas at the moment
#			Tachimanga
#			Paperback
			;
		};
	};

	system = {
		stateVersion = 4;
		activationScripts.postUserActivation.text = ''
		# Following line should allow us to avoid a logout/login cycle
		/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
		'';
		defaults = {
			dock = {
				expose-group-by-app = true;
				showhidden = true;
				tilesize = 30;
			};
			finder = {
				AppleShowAllExtensions = true;
				AppleShowAllFiles = true;
				ShowPathbar = true;
				ShowStatusBar = true;
			};
			menuExtraClock.Show24Hour = true;
			NSGlobalDomain = {
				"com.apple.mouse.tapBehavior" = null;
				"com.apple.swipescrolldirection" = true;
				"com.apple.trackpad.enableSecondaryClick" = true;
				AppleEnableMouseSwipeNavigateWithScrolls = true;
				AppleEnableSwipeNavigateWithScrolls = true;
				AppleInterfaceStyle = "Dark";
				AppleInterfaceStyleSwitchesAutomatically = null; # bool
				AppleMeasurementUnits = "Centimeters";
				AppleMetricUnits = null; # 0, 1
				AppleTemperatureUnit = "Celsius";
				InitialKeyRepeat = null; # signed int
				KeyRepeat = null; # signed int
				NSAutomaticCapitalizationEnabled = false;
				NSAutomaticDashSubstitutionEnabled = false;
				NSAutomaticPeriodSubstitutionEnabled = false;
				NSAutomaticQuoteSubstitutionEnabled = false;
				NSAutomaticSpellingCorrectionEnabled = false;
				NSDocumentSaveNewDocumentsToCloud = false;
			};
			screencapture.type = "png";
			spaces.spans-displays = false;
			trackpad = {
				Dragging = false;
				TrackpadRightClick = true;
				TrackpadThreeFingerDrag = true;
			};
#			"com.apple.Safari" = {
#				AutoFillFromiCloudKeychain = 0;
#				AutoFillPasswords = 0; # I don't think I can link in with 1Password
#				"com.apple.Safari.WebKitPreferences.developerExtrasEnabled" = 1;
#			};
		};
	};
}

