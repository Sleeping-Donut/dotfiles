#
#  Specific system configuration settings for MacBook
#
#  flake.nix
#   └─ ./darwin
#       ├─ ./default.nix
#       └─ ./configuration.nix *
#

{ config, pkgs, user, system, hostname, nix-homebrew, ... }:

{

	users.users."${user}" = {
		home = "/Users/${user}";
		shell = pkgs.zsh;
	};

	networking = {										# Move this to be in the individual's one not the default
		computerName = hostname;
		hostName = hostname;
	};

	fonts = {
		fontDir.enable = true;
		fonts = with pkgs; [
			font-awesome
			roboto
			roboto-mono
			noto-fonts
			(nerdfonts.override {
				fonts = [ "FiraCode" ];
			})
		];
	};

	environment = {
		shells = with pkgs; [ zsh ];						# Default shell
		variables = {									# System variables
			EDITOR = "nvim";
			VISUAL = "nvim";
		};

		systemPackages = with pkgs; [
			# Terminal
			git
		];
	};

	programs = {
		zsh.enable = true;
	};

	services = {
		nix-daemon.enable = true;						# Auto upgrade daemon
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

		# taps = [
		# 	"homebrew/casks"
		# 	"homebrew/cask-drivers"
		# ];

		# brews = [];

		# casks = [];

		# masApps = {};
	};

	nix = {
		package = pkgs.nix;
		gc = {											# garbage Collection
			automatic = true;
			interval.Day = 14;
			options = "--delete-older-than 14d";
		};
		extraOptions = ''
		auto-optimise-store = true
		experimental-features = nix-command flakes
		'';
	};

	system = {
		stateVersion = 4;
		activationScripts.postUserActivation.text = ''
		# Following line should allow us to avoid a logout/login cycle
		/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
		'';
		defaults = {
			NSGlobalDomain = {							# Global macOS System Settings
				NSAutomaticCapitalizationEnabled = false;
			};
			dock = {									# Dock Settings
				autohide = false;
				orientation = "bottom";
				# showhidden = true;
				tilesize = 30;
			};
			finder = {									# Finder Settings
				# stuff from other file
			};
			trackpad = {								# Trackpad Settings
				Clicking = true;
				TrackpadRightClick = true;
			};
		};
	};
}
