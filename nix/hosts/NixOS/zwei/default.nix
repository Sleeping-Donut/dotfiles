{
	config, lib, pkgs,
	pkgs-unstable,
	nix-modules, nixos-modules, overrides, own-pkgs,
	hostname ? "zwei", system,
	inputs,
	...
}:
let
	plex-versioned = import overrides.plex-versioned { inherit pkgs; };
	keys = import nix-modules.keys {};
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
		gc.automatic = true;
		gc.dates = "weekly";
		gc.options = "--delete-older-than 30d";
		optimise.automatic = true;
	};

	networking = {
		hostName = hostname;
		networkmanager.enable = true;
		firewall = {
			enable = true;
			allowedTCPPorts = [ 8443 ]; # Unifi remote login
			# allowedUDPPorts = [];
		};
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
			"x-systemd.automount" # noauto | automount
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

#	System packages
	environment.systemPackages = with pkgs-unstable; [
		curl
		dua
		duf
		dust
		fd
		git
		neovim
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
	services.tailscale.enable = true;

	services.plex = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/plex/data";
		extraScanners = [];
		extraPlugins = [];
		openFirewall = true;
		package = plex-versioned {
			version = "1.41.5.9522-a96edc606";
#			To get hash for new version use `sh nix/scripts/getPkgHash 'plex' '<VERSION>'
			hash = "sha256-3bGmsa2OLBt587YnZDNpSjWHdQ1ubwSNocLPW6A6kQU=";
		};
	};

	services.jellyfin = let
		jellyDir = "/opt/jellyfin";
	in {
		enable = true;
		group = "labmembers";
		dataDir = "${jellyDir}/data";
		logDir = "${jellyDir}/logs";
		configDir = "${jellyDir}/config";
		cacheDir = "${jellyDir}/cache";
		openFirewall = true;
		package = pkgs-unstable.jellyfin;
	};

	services.unifi = {
		enable = true;
		maximumJavaHeapSize = 2048;
		openFirewall = true;
		unifiPackage = pkgs-unstable.unifi;
		mongodbPackage = pkgs.mongodb-ce;
		# Files have to be in `/var/lib/unifi` (╥‸╥)
	};

	services.prometheus = {
		package = pkgs-unstable.prometheus;

		# Client to monitor system
		exporters.node = {
			enable = true;
			port = 9001;
			openFirewall = true;
			enabledCollectors = [ "systemd" ];
			extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" ];
		};

		# Server to collect the data
		enable = true;
		port = 9039;
		globalConfig.scrape_interval = "10s";
		scrapeConfigs = [
			{
				job_name = "node_clients";
				static_configs = [
					{ targets = [ "localhost:9001" ]; }
					{ targets = [ "vcu.fglab:9001" ]; }
				];
			}
		];
	};
	services.grafana = {
		enable = true;
		package = pkgs-unstable.grafana;
		dataDir = "/opt/grafana";
		settings = {
			server = {
				http_addr = "127.0.0.1";
				http_port = 3000;
				enforce_domain = false;
				serve_from_sub_path = false;
			};
		};
		provision.datasources.settings.datasources = [
			{
				name = "prometheus";
				type = "prometheus";
				access = "proxy";
				isDefault = true;
				url = "localhost:${toString config.services.prometheus.port}";
			}
		];
	};

	# To handle SSL
	# security.acme = { acceptTerms = true; defaults.email = ""; };
	services.nginx.enable = true;
	services.nginx.virtualHosts = let
		localDomain = "fglab";
		tailnet = "tail4fc89.ts.net";
		vcu = "vcu.${localDomain}";
		zwei = "zwei.${localDomain}";
		zweiTail = "zwei.${tailnet}";
		toUrl = domain: port: "http://${domain}:${toString port}";
	in {
		"${zwei}".locations."/" = {
			proxyPass = toUrl vcu "5000";
		};
		"grafana.${zwei}" = {
			serverAliases = [ "grafana.${zweiTail}" ];
			locations."/".proxyPass = toUrl zwei config.services.grafana.settings.server.http_port;
		};
		"plex.${zwei}" = {
			serverAliases = [ "plex.${zweiTail}" ];
			locations."/".proxyPass = toUrl zwei 32400;
		};
		"transmission.${zwei}" = {
			serverAliases = [ "transmission.${zweiTail}" ];
			locations."/".proxyPass = "${toUrl vcu 9091}/transmission";
		};
		"sonarr.${zwei}" = {
			serverAliases = [ "sonarr.${zweiTail}" ];
			locations."/".proxyPass = toUrl vcu 8989;
		};
		"radarr.${zwei}" = {
			serverAliases = [ "radarr.${zweiTail}" ];
			locations."/".proxyPass = toUrl vcu 7878;
		};
		"lidarr.${zwei}" = {
			serverAliases = [ "lidarr.${zweiTail}" ];
			locations."/".proxyPass = toUrl vcu 8686;
		};
		"readarr.${zwei}" = {
			serverAliases = [ "readarr.${zweiTail}" ];
			locations."/".proxyPass = toUrl vcu 8787;
		};
	};

#	Home Configs
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
			keys.s24u
		];
	};

	users.users.plex = {
		isSystemUser = true;
		description = "Plex media server service account";
		group = "labmembers";
	};

#	Groups
	users.groups.labmembers.gid = 8596;
}

