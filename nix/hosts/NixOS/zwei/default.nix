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
				http_addr = "0.0.0.0";
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
			locations = {
				"/" = {
					# proxyPass = toUrl vcu "5000";
					return = "200 \"At least this is running\"";
					extraConfig = ''
						add_header Content-Type text/plain;
					'';
				};
				"/grafana" = {
					proxyPass = toUrl zwei config.services.grafana.settings.server.http_port;
					proxyWebsockets = true;
					extraConfig = ''
						proxy_set_header Host $host;
						proxy_set_header X-Real-IP $remote_addr;
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header X-Forwarded-Proto $scheme;
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
				"/sonarr" = {
					proxyPass = toUrl vcu 8989;
					proxyWebsockets = true;
					extraConfig = ''
						proxy_set_header Host $host;
						proxy_set_header X-Real-IP $remote_addr;
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header X-Forwarded-Proto $scheme;
					'';
				};
				"/radarr" = {
					proxyPass = toUrl vcu 7878;
					proxyWebsockets = true;
					extraConfig = ''
						#proxy_set_header Host $host;
						#proxy_set_header X-Real-IP $remote_addr;
						#proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						#proxy_set_header X-Forwarded-Proto $scheme;

						proxy_set_header Host $host;
						proxy_set_header X-Forwarded-Host $host;
						proxy_set_header X-Forwarded-Proto $scheme;
						proxy_redirect off;
						proxy_http_version 1.1;

						proxy_set_header Upgrade $http_upgrade;
						proxy_set_header Connection $http_connection;

					'';
				};
				"/radarr/api/" = {
					proxyPass = "${toUrl vcu 7878}/api/";
					extraConfig = ''
						auth_basic off;
						proxy_set_header Host $host;
						proxy_set_header X-Real-IP $remote_addr;
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header X-Forwarded-Proto $scheme;
					'';
				};
				"/lidarr" = {
					proxyPass = toUrl vcu 8686;
					proxyWebsockets = true;
					extraConfig = ''
						proxy_set_header Host $host;
						proxy_set_header X-Real-IP $remote_addr;
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header X-Forwarded-Proto $scheme;
					'';
				};
				"/readarr" = {
					proxyPass = toUrl vcu 8787;
					proxyWebsockets = true;
					extraConfig = ''
						proxy_set_header Host $host;
						proxy_set_header X-Real-IP $remote_addr;
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header X-Forwarded-Proto $scheme;
					'';
				};
				"/transmission" = {
					proxyPass = (toUrl vcu 9091) + "/transmission/";
					proxyWebsockets = true;
					extraConfig = ''
						proxy_set_header Host $host;
						proxy_set_header X-Real-IP $remote_addr;
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header X-Forwarded-Proto $scheme;

						# --- Handle 409 Conflict for Transmission Session ID ---
						# If Transmission returns a 409 error (missing session ID),
						# Nginx will internally redirect to the @transmission_reload location.
						error_page 409 = @transmission_reload;
					'';
				};
				# --- Named location to handle the 409 Session ID reload ---
				# This location is triggered internally by Nginx when a 409 error
				# is received by the /transmission/ location.
				"@transmission_reload" = {
					extraConfig = ''
						# Add the X-Transmission-Session-Id header received from the backend
						# to the response sent back to the client.
						add_header X-Transmission-Session-Id $upstream_http_x_transmission_session_id;
						# Return a 302 redirect to the original requested URI.
						# This tells the browser to resend the request, and the browser
						# should now include the X-Transmission-Session-Id header it just received.
						return 302 $request_uri;
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

