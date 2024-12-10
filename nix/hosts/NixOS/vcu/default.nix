{
	config, lib, pkgs,
	pkgs-unstable,
	nix-modules, nixos-modules, overrides, own-pkgs,
	hostname ? "vcu", system,
	inputs,
	...
}:
let
	keys = import nix-modules.keys {};
	transmission_pinned = let
		pkgsPinned = import inputs.nixpkgs-transmission-safe { inherit system; };
		transmission_pinned = pkgsPinned.transmission_4;
	in
		transmission_pinned;
in
{
	imports = [
		./hardware-configuration.nix

		nixos-modules.bazarr
		nixos-modules.ombi
		nixos-modules.prowlarr
	];

#	This defines first version of nixos installed - used to maintain
#	 compatibility with application data (e.g. databases)
#	Most users should NEVER update this value even when updating nixos
#	Do NOT change this value unless you have manually inspected all changes it
#	 would make to your configuration and migrated your data accordingly
	system.stateVersion = "23.11"; # Did you read the comment?

	nix = {
		gc.automatic = true;
		gc.dates = "weekly";
		gc.options = "--delete-older-than 30d";
		optimise.autiomatic = true;
	};

	networking = {
		hostName = hostname;
		networkmanager.enable = true;
		extraHosts = ''
			127.0.0.1		vcu.fglab
			192.168.10.124	whitefox.fglab
			192.168.10.114	zwei.fglab
		'';
	};

#	Use systemd-boot EFI bootloader
	boot.loader.systemd-boot.enable = true;
	boot.loader.systemd-boot.configurationLimit = 8;
	boot.loader.efi.canTouchEfiVariables = true;

	fileSystems."/mnt/amadeus/fg8" = {
		device = "whitefox.fglab:/mnt/amadeus/fg8";
		fsType = "nfs";
		options = [
			"nfsvers=4.2"
			"x-systemd.noauto" #"noauto" # automount
			"x-systemd.idle-timeout=1200" # disconnects after 20 minutes (i.e. 1200 seconds)
		];
	};

	time.timeZone = "GB";

	i18n.defaultLocale = "en_GB.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "en_GB.UTF-8";
		LC_IDENTIFICATION = "en_GB.UTF-8";
		LC_MEASUREMENT = "en_GB.UTF-8";
		LC_MONETARY = "en_GB.UTF-8";
		LC_NAME = "en_GB.UTF-8";
		LC_NUMERIC = "en_GB.UTF-8";
		LC_PAPER = "en_GB.UTF-8";
		LC_TELEPHONE = "en_GB.UTF-8";
		LC_TIME = "en_GB.UTF-8";
	};
	console = {
		font = "Lat2-Terminus16";
		keyMap = "uk";
	};

#	To enable sound
	sound.enable = true;
	hardware.pulseaudio.enable = true;

#	System packages
	environment.systemPackages = with pkgs-unstable; [
		curl
		git
		vim
		wget
	];
	programs.tmux = {
		enable = true;
		baseIndex = 1;
		keyMode = "vi";
		extraConfig = "set-option -g prefix2 C-'\\'";
	};

#	GNOME stuff
	services.xserver.enable = true;
	services.xserver.displayManager.gdm = {
		enable = true;
		wayland = true;
		autoSuspend = false;
	};
	services.xserver.desktopManager.gnome = {
		enable = true;

		extraGSettingsOverridePackages = with pkgs; [gnome.gnome-settings-daemon];
#		Disable suspend when on AC power
		extraGSettingsOverrides = ''
			[org.gnome.settings-daemon.plugins.power]
			sleep-inactive-ac-timeout=0
			sleep-inactive-ac-type='nothing'
		'';
	};
	services.gnome = {
		gnome-remote-desktop.enable = true;
	};
	environment.gnome.excludePackages = (with pkgs; [
		gnome-photos
		gnome-tour
		snapshot
	]) ++ (with pkgs.gnome; [
		cheese
		gnome-music
		epiphany
#		etc.
	]);
	services.xserver.excludePackages = (with pkgs; [ xterm ]);

#	System Services
	services.openssh.enable = true;
	services.tailscale.enable = true;

	services.mullvad-vpn = {
		enable = true;
		package = pkgs-unstable.mullvad-vpn;
		enableExcludeWrapper = false;
	};
#	TODO: make custom config dir work (below)
#	environment.etc."mullvad-vpn".source = "/opt/mullvad";
#	environment.variables."MULLVAD_SETTINGS_DIR" = "/opt/mullvad";
#	NOTE: required otherwise mullvad cant resolve DNS correctly
	services.resolved.enable = true;

	nd0.services.prowlarr = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/prowlarr/data";
		openFirewall = true;
		package = pkgs-unstable.prowlarr;
	};

	services.sonarr = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/sonarr/data";
		openFirewall = true;
		package = pkgs-unstable.sonarr;
	};
	services.radarr = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/radarr/data";
		openFirewall = true;
		package = pkgs-unstable.radarr;
	};
	nd0.services.bazarr = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/bazarr/data";
		openFirewall = true;
		package = pkgs-unstable.bazarr;
	};
	services.lidarr = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/lidarr/data";
		openFirewall = true;
		package = pkgs-unstable.lidarr;
	};
	services.readarr = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/readarr/data";
		openFirewall = true;
		package = pkgs-unstable.readarr;
	};
	nd0.services.ombi = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/ombi/data";
		openFirewall = true;
		package = pkgs-unstable.ombi;
	};
	services.tautulli = {
		enable = true;
		user = "tautulli";
		group = "labmembers";
		dataDir = "/opt/tautulli/data";
		configFile = "/opt/tautulli/config.ini";
		openFirewall = true;
		package = pkgs-unstable.tautulli;
	};

	systemd.services.transmission.serviceConfig = {
		# transmission service wants to set this to 0066 for some reason
		UMask = lib.mkForce "0007";
	};
	services.transmission = {
		enable = true;
		user = "transmission";
		group = "labmembers";
		home = "/opt/transmission/home";
		openFirewall = false;
		openRPCPort = true;
		downloadDirPermissions = "770";
		package = transmission_pinned;
		settings = {
			alt-speed-down = 500;
			alt-speed-enabled = false;
			alt-speed-time-begin = 540;
			alt-speed-time-day = 127;
			alt-speed-time-enabled = false;
			alt-speed-time-end = 1020;
			alt-speed-up = 500;
			blocklist-enabled = false;
			compact-view = false;
			dht-enabled = true;
			download-dir = "/mnt/amadeus/fg8/Pending/Unsorted";
			download-queue-enabled = true;
			download-queue-size = 20;
			encryption = 1;
			idle-seeding-limit = 30;
			idle-seeding-limit-enabled = false;
			incomplete-dir = "/mnt/amadeus/fg8/Pending/Unsorted/Incomplete";
			incomplete-dir-enabled = true;
			queue-stalled-enabled = true;
			queue-stalled-minutes = 30; # minutes
			rpc-authentication-required = false;
			rpc-bind-address = "0.0.0.0"; # Listen on all interfaces
			rpc-host-whitelist-enabled = false;
			rpc-whitelist-enabled = false;
			seed-queue-enabled = true;
			seed-queue-size = 40;
			umask = 7; # subtract from permissions so ___ - 007 = 770
		};
	};
#	TODO: suwayomi, prometheus

	services.nginx.virtualHosts = let
		localDomain = "fglab";
		vcu = "vcu.${localDomain}";
		zwei = "zwei.${localDomain}";
		toUrl = domain: port: "http://${domain}:${port}";
	in {
		"${vcu}".locations."/" = {
			proxyPass = toUrl vcu "5000";
		};
		"plex.${vcu}".locations."/" = {
			proxyPass = toUrl vcu "32400";
		};
		"transmission.${vcu}".locations."/" = {
			proxyPass = "${toUrl vcu "9091"}/transmission";
		};
		"sonarr.${vcu}".locations."/" = {
			proxyPass = toUrl vcu "8989";
		};
		"radarr.${vcu}".locations."/" = {
			proxyPass = toUrl vcu "7878";
		};
		"lidarr.${vcu}".locations."/" = {
			proxyPass = toUrl vcu "8686";
		};
		"readarr.${vcu}".locations."/" = {
			proxyPass = toUrl vcu "8787";
		};
	};

#	Firewall
#	networking.firewall = { enable = true; allowedTCPPorts = []; allowedUDPPorts = []; };

#	Groups
	users.groups.labmembers.gid = 8596;

# Home configs
	home-manager = {
		users.nathand = import ./nathand.nix;
	};

#	Users
	users.users.nathand = {
		isNormalUser = true;
		description = "Nathan";
		extraGroups = [ "wheel" "networkmanager" "labmembers" ];
		openssh.authorizedKeys.keys = [
			keys.LHC
			keys.dogwater
		];
	};

	users.users.tautulli = {
		isSystemUser = true;
		description = "Tautulli service account";
		group = "labmembers";
	};
}

