{
	config, lib, pkgs,
	pkgs-unstable,
	hostname ? "zwei",
	nixos-modules,
	...
}:
let
	plex-versioned = (args@{version, hash}:
		pkgs.plex.override {
			plexRaw = pkgs.plexRaw.overrideAttrs(old: rec {
				inherit version;
				src = pkgs.fetchurl {
					name = "plex-${version}";
					url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
					hash = hash;
				};
			});
		}
	);
in
{
	imports = [
		./hardware-configuration.nix
	];

#	This defines first version of nixos installed - used to maintain
#	 compatibility with application data (e.g. databases)
#	Most users should NEVER update this value even when updating nixos
#	Do NOT change this value unless you have manually inspected all changes it
#	 would make to your configuration and migrated your data accordingly
	system.stateVersion = "23.11"; # Did you read the comment?

	nix = {
		gc.dates = "monthly";
	};

	networking = {
		hostName = hostname;
		networkmanager.enable = true;
	};

#	Use systemd-boot EFI bootloader
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

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

#	System Services
	services.openssh.enable = true;

	services.plex = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/plex/data";
		extraScanners = [];
		extraPlugins = [];
		openFirewall = true;
		package = plex-versioned {
			version = "1.40.2.8395-c67dce28e";
			hash = "sha256-gYRhQIf6RaXgFTaigFW1yJ7ndxRmOP6oJSNnr8o0EBM=";
		};
	};

#	Firewall
#	networking.firewall = { enable = true; allowedTCPPorts = []; allowedUDPPorts = []; };

#	Users
	users.users.nathand = import ./nathand.nix;

	users.users.plex = {
		isSystemUser = true;
		description = "Plex media server service account";
		group = "labmembers";
	};

#	Groups
	users.groups.labmembers.gid = 8596;
}

