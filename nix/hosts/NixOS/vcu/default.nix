{
	config, lib, pkgs,
	pkgs-unstable,
	hostname ? "vcu",
	...
}:
let
in
{
	imports = [
#		./hardware-configuration.nix
	];

#	This defines first version of nixos installed - used to maintain
#	 compatibility with application data (e.g. databases)
#	Most users should NEVER update this value even when updating nixos
#	Do NOT change this value unless you have manually inspected all changes it
#	 would make to your configuration and migrated your data accordingly
	system.stateVersion = "23.11"; # Did you read the comment?

	networking = {
		hostName = hostname;
		networkmanager.enable = true;
	};

#	Use systemd-boot EFI bootloader
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	fileSystems."/" = {
		device = "";
		fsType = "";
	};
	swapDevices = [];
	fileSystems."/mnt/amadeus/fg8" = {
		device = "whitefox.fglab:/mnt/amadeus/fg8";
		fsType = "nfs";
		options = [
			"nfsvers=4.2"
			"x-systemd.automount" "noauto" # automount
			"x-systemd.idle-timeout=1200" # disconnects after 20 minutes (i.e. 1200 seconds)
		];
	};

	time.timeZone = "GB";

	i18n.defaultLocale = "en_GB.UTF-8";
	console = {
		font = "Lat2-Terminus16";
		keyMap = "uk";
		useXkbConfig = true; # for xkb.options in tty
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

#	System Services
	services.openssh.enable = true;
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
	services.ombi = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/ombi/data";
		openFirewall = true;
		package = pkgs-unstable.ombi;
	};
	services.tautulli = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/tautulli/data";
		configFile = "/opt/tautulli-config.ini";
		openFirewall = true;
		package = pkgs-unstable.tautulli;
	};
	services.transmission = {
		enable = true;
		group = "labmembers";
		home = "/opt/transmission/home";
		openFirewall = true;
		openPeerPorts = true;
		package = pkgs-unstable.transmission;
		settings = {};
	};
	services.mullvad-vpn = {
		enable = true;
		package = pkgs-unstable.mullvad;
	};
#	TODO: suwayomi, prometheus

#	Firewall
#	networking.firewall = { enable = true; allowedTCPPorts = []; allowedUDPPorts = []; };

#	Users
	users.users.nathand = import ./nathand.nix;

	users.users.sonarr = {
		isSystemUser = true;
		description = "Sonarr service account";
		group = "labmembers";
	};
	users.users.radarr = {
		isSystemUser = true;
		description = "Radarr service account";
		group = "labmembers";
	};
	users.users.lidarr = {
		isSystemUser = true;
		description = "Radarr service account";
		group = "labmembers";
	};
	users.users.readarr = {
		isSystemUser = true;
		description = "Readarr service account";
		group = "labmembers";
	};
	users.users.ombi = {
		isSystemUser = true;
		description = "Ombi service acccount";
		group = "labmembers";
	};
	users.users.tautulli = {
		isSystemUser = true;
		description = "Tautulli service account";
		group = "labmembers";
	};
	users.users.transmission = {
		isSystemUser = true;
		description = "Transmission service account";
		group = "labmembers";
	};

#	Groups
	users.groups.labmembers.gid = 8596;
}

