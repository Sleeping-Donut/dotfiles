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
			allowedTCPPorts = [
				80 # nginx
				8443 # Unifi remote login
			];
			# allowedUDPPorts = [];
		};
		extraHosts = ''
			127.0.0.1		zwei.fglab
			192.168.10.124	whitefox.fglab
			192.168.10.117	vcu.fglab
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
	services.tailscale = {
		enable = true;
		package = pkgs-unstable.tailscale;
	};

	services.plex = {
		enable = true;
		group = "labmembers";
		dataDir = "/opt/plex/data";
		extraScanners = [];
		extraPlugins = [];
		openFirewall = true;
		package = plex-versioned {
			version = "1.41.7.9749-ce0b45d6e";
#			To get hash for new version use `sh nix/scripts/getPkgHash 'plex' '<VERSION>'
			hash = "sha256-QeYWgQ4V56gRBw7E12ibx9RPqKkJ3jX61HcbZyQtlvI=";
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
		enable = false;
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
			enabledCollectors = [ "systemd" "various_sensors" ];
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
					{ targets = [ "zwei.fglab:9001" ]; }
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
				http_addr = "0.0.0.0";
				http_port = 3000;
				enforce_domain = false;
				serve_from_sub_path = true;
				# domain = "zwei.fglab";
				root_url = "http://zwei.fglab/grafana/";
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
	services.nginx = let
		localDomain = "fglab";
		tailnet = "time-augmented.ts.net";
		vcu = "vcu.${localDomain}";
		zwei = "zwei.${localDomain}";
		zweiTail = "zwei.${tailnet}";
		toUrl = domain: port: "http://${domain}:${toString port}";
	in {
		enable = true;

		# recommendedGzipSettings = true;
		# recommendedOptimisation = true;
		# recommendedProxySettings = true;
		# recommendedTlsSettings = true;

		# Increased to avoid warnings
		serverNamesHashBucketSize = 1024;
		serverNamesHashMaxSize = 128;

		virtualHosts."${zwei}" = {
			serverAliases = [ zweiTail ];
			locations = let
				arrConfig = service: port: let
					servicePath = "/${service}";
					apiPath = if service == "prowlarr" then
						"/prowlarr(/[0-9]+)?/api"
					else
						"/${service}/api";
				in {
					"${servicePath}" = {
						proxyPass = toUrl vcu port;
						proxyWebsockets = true;
						extraConfig = ''
							proxy_set_header Host $host;
							proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
							proxy_set_header X-Forwarded-Host $host;
							proxy_set_header X-Forwarded-Proto $scheme;
							proxy_redirect off;
						'';
					};
					"${apiPath}" = {
						proxyPass = "${toUrl vcu port}";
						extraConfig = ''
							auth_basic off;
						'';
					};
				};
				arrServices = {}
					// (arrConfig "sonarr" 8989)
					// (arrConfig "radarr" 7878)
					// (arrConfig "lidarr" 8686)
					// (arrConfig "readarr" 8787)
					// (arrConfig "prowlarr" 9696)
				;
			in  arrServices // {
				"/" = {
					# proxyPass = toUrl vcu "5000";
					return = "200 \"At least this is running\"";
					extraConfig = ''
						add_header Content-Type text/plain;
					'';
				};
				"/grafana/" = let
					grafanaUrl = toUrl zwei config.services.grafana.settings.server.http_port;
				in {
					proxyPass = "${grafanaUrl}";
					proxyWebsockets = true;
					extraConfig = ''
						proxy_set_header Host $host;
					#	proxy_set_header X-Real-IP $remote_addr;
					#	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					#	proxy_set_header X-Forwarded-Proto $scheme;
					#	proxy_redirect ${grafanaUrl}/ /grafana/;
					'';
				};
				"/grafana/api/live/" = let
					grafanaUrl = toUrl zwei config.services.grafana.settings.server.http_port;
				in {
					proxyPass = "${grafanaUrl}";
					proxyWebsockets = true;
					extraConfig = ''
						proxy_set_header Host $host;
					'';

				};
				"/plex" = {
					proxyPass = toUrl vcu 32400;
					proxyWebsockets = true;
					extraConfig = ''
						proxy_set_header Host $host;
						proxy_set_header X-Real-IP $remote_addr;
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header X-Forwarded-Proto $scheme;
						# Additional headers often recommended for Plex
						proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
						proxy_set_header X-Plex-Device $http_x_plex_device;
						proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
						proxy_set_header X-Plex-Platform $http_x_plex_platform;
						proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
						proxy_set_header X-Plex-Provides $http_x_plex_provides;
						proxy_set_header X-Plex-Product $http_x_plex_product;
						proxy_set_header X-Plex-Version $http_x_plex_version;
						proxy_set_header X-Plex-Device-Screen-Resolution $http_x_plex_device_screen_resolution;
						proxy_set_header X-Plex-Token $http_x_plex_token;
					'';
				};
				"/transmission" = {
					proxyPass = (toUrl vcu 9091);
					proxyWebsockets = true;
					extraConfig = ''
						proxy_pass_header  X-Transmission-Session-Id;
						proxy_set_header   X-Forwarded-Host $host;
						proxy_set_header   X-Forwarded-Server $host;
						proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_read_timeout 300;
					'';
				};
			};
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

