{
  config,
  pkgs,
  lib,
  system,
  pkgs-unstable,
  hostname ? "zwei",
  repo-root,
  inputs,
  sources,
  modules,
  ...
}:
let
  plex-versioned = import sources.overrides.plex-versioned { inherit pkgs; };
  keys = import modules.common.keys;
  publicDomain =
    "media"
    + "centre"
    + "hub"
    + "."
    + "com";
in
{
  imports = [
    ./hardware-configuration.nix
    (repo-root + "/nix/modules/nixos/rclone-backups.nix")
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
        80 # nginx HTTP
        443 # nginx HTTPS
        8443 # Unifi remote login
        8082 # kavita
      ];
      # allowedUDPPorts = [];
    };
    extraHosts = ''
      127.0.0.1         zwei.fglab
      192.168.10.124    whitefox.fglab
      192.168.10.117    vcu.fglab
      127.0.0.1         immich.zwei.fglab
      127.0.0.1         kavita.zwei.fglab
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

  #	Groups
  users.groups.labmembers.gid = 8596;

  users.users.nathand = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [
      "wheel"
      "networkmanager"
      "labmembers"
    ];
    openssh.authorizedKeys.keys = [
      keys.LHC
      keys.s24u
    ];
  };

  #	Home Configs
  home-manager = {
    users.nathand = import ./nathand.nix;
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
    nh
    nix-output-monitor
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

  users.users.plex = {
    uid = 193;
    isSystemUser = true;
    description = "Plex media server service account";
    group = "labmembers";
  };
  services.plex = {
    enable = true;
    group = "labmembers";
    dataDir = "/opt/plex/data";
    extraScanners = [ ];
    extraPlugins = [ ];
    openFirewall = true;
    package = plex-versioned {
      version = "1.43.2.10687-563d026ea";
      #			To get hash for new version use `sh nix/scripts/getPkgHash.sh 'plex' '<VERSION>'
      hash = "sha256-dgkj0Uny/d0DnExgYWjxfl2cFsiattlGzb7Guzmtro4=";
    };
  };
  nd0.rclone-backups.plex = {
    enable = false;
    sourceDir = "/opt/plex/data/Plex Media Server";
    destDir = "/mnt/amadeus/fg8/Backup/plex/Plex Media Server";
    group = "labmembers";
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:00:00" ]; # weekly at 0300 Sun
    whitelist = [
      "/Preferences.xml"
      "/Metadata/**"
      "/.LocalAdminToken"
      "/Plug-in Support/**"
      "/Plug-ins/**"
      "/Codecs/**"
      "/Scanners/**"
      "/Cache/**"
      "/Logs/**"
      "/Crash Reports/**"
      "/Diagnostics/**"
    ];
  };

  users.users.jellyfin = {
    uid = 995;
    isSystemUser = true;
    description = "Jellyfin Server service account";
    group = "labmembers";
  };
  services.jellyfin =
    let
      jellyDir = "/opt/jellyfin";
    in
    {
      enable = true;
      group = "labmembers";
      dataDir = "${jellyDir}/data";
      logDir = "${jellyDir}/logs";
      configDir = "${jellyDir}/config";
      cacheDir = "${jellyDir}/cache";
      openFirewall = true;
      package = pkgs-unstable.jellyfin;
    };
  nd0.rclone-backups.jellyfin = {
    enable = false;
    sourceDir = "/opt/jellyfin";
    destDir = "/mnt/amadeus/fg8/Backup/jellyfin";
    group = "labmembers";
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:15:00" ]; # weekly at 0300 Sun
  };

  users.users.kavita.extraGroups = [ "labmembers" ];
  services.kavita = {
    enable = true;
    dataDir = "/opt/kavita/data";
    tokenKeyFile = "/opt/kavita/kavita-token-key";
    settings = {
      Port = 8082;
      BaseUrl = "/kavita/";
    };
  };
  nd0.rclone-backups.kavita = {
    enable = false;
    sourceDir = "/opt/kavita";
    destDir = "/mnt/amadeus/fg8/Backup/kavita";
    group = "labmembers";
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:30:00" ]; # Weekly at 03:30 Sun
    whitelist = [
      "/kavita-token-key"
      "/data/config/kavita.db"
      "/data/config/appsettings.json"
      "/data/config/covers/**"
      "/data/config/bookmarks/**"
      "/data/config/themes/**"
      "/data/config/favicons/**"
    ];
  };

  users.users.audiobookshelf = {
    extraGroups = [ "labmembers" ];
    home = lib.mkForce "/opt/audiobookshelf/data"; # the module has a path for this so just in case, override
  };
  systemd.tmpfiles.settings.audiobookshelf-data = {
    "/opt/audiobookshelf/data" = {
      d = {
        user = "audiobookshelf";
        group = "audiobookshelf";
        mode = "0750";
      };
    };
  };
  systemd.services.audiobookshelf.serviceConfig = {
    WorkingDirectory = lib.mkForce "/opt/audiobookshelf/data";
  };
  services.audiobookshelf = {
    enable = true;
    package = pkgs-unstable.audiobookshelf;
    dataDir = "/opt/audiobookshelf/data";
    port = 13378;
    openFirewall = true;
  };
  nd0.rclone-backups.audiobookshelf = {
    enable = false;
    sourceDir = config.services.audiobookshelf.dataDir;
    destDir = "/mnt/amadeus/fg8/Backup/audiobookshelf/data";
    group = "labmembers";
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:45:00" ]; # weekly at 03:45 Sun
    whitelist = [
      "/config/**"
      "/metadata/items/**"
      "/metadata/authors/**"
      "/metadata/backups/**"
    ];
  };

  users.users.immich.extraGroups = [ "labmembers" ];
  systemd.tmpfiles.settings.immich-state = {
    "/opt/immich" = {
      d = {
        user = "immich";
        group = "immich";
        mode = "0700";
      };
    };
  };
  systemd.tmpfiles.settings.immich-media = lib.mkForce {}; # mediaLocation on NFS, no tmpfiles meddling
  systemd.services.immich-server.serviceConfig = {
    PrivateMounts = lib.mkForce false;   # needed for NFS automount propagation
    PrivateUsers = lib.mkForce false;    # needed for NFS UID mapping
  };
  services.immich = {
    enable = true;
    package = pkgs-unstable.immich;
    host = "127.0.0.1";
    mediaLocation = "/mnt/amadeus/fg8/Media/Photos";
    # port = 2283; # default
    openFirewall = true;
    machine-learning.enable = false; # no hw ;(
  };
  nd0.rclone-backups.immich = {
    enable = false;
    sourceDir = "/opt/immich";
    destDir = "/mnt/amadeus/fg8/Backup/immich";
    group = "labmembers";
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:50:00" ]; # weekly at 03:50 Sun
  };

  services.unifi = {
    enable = false;
    maximumJavaHeapSize = 2048;
    openFirewall = true;
    unifiPackage = pkgs-unstable.unifi;
    mongodbPackage = pkgs.mongodb-ce;
    # Files have to be in `/var/lib/unifi` (╥‸╥)
  };

  users.users.pocket-id.extraGroups = [ "labmembers" ];
  systemd.tmpfiles.settings.pocket-id = {
    "/opt/pocket-id/data" = {
      d = {
        user = "pocket-id";
        group = "pocket-id";
        mode = "0700";
      };
    };
  };
  services.pocket-id = {
    enable = true;
    dataDir = "/opt/pocket-id/data";
    settings = {
      APP_URL = "https://id.${publicDomain}";
      TRUST_PROXY = true;
      HOST = "127.0.0.1";
      PORT = 1411;
    };
    credentials = {
      ENCRYPTION_KEY = "/opt/pocket-id/encryption-key";
    };
  };

  systemd.services.healthcheck = {
    description = "Health check HTTP server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.python3} ${./healthcheck.py} 8083";
      Restart = "always";
      DynamicUser = true;
    };
  };

  services.prometheus = {
    package = pkgs-unstable.prometheus;

    # Client to monitor system
    exporters.node = {
      enable = true;
      port = 9001;
      openFirewall = true;
      enabledCollectors = [
        "systemd"
        "processes"
      ];
      extraFlags = [
        "--collector.ethtool"
        "--collector.softirqs"
        "--collector.tcpstat"
      ];
    };
    exporters.smartctl = {
      enable = true;
      openFirewall = true;
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

  users.users.grafana = {
    # just to keep uid between installs
    uid = 196;
    isSystemUser = true;
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
      security.secret_key = "SW2YcwTIb9zpOOhoPsMm"; # Shhh its very secret
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
  nd0.rclone-backups.grafana = {
    enable = false;
    sourceDir = config.services.grafana.dataDir;
    destDir = "/mnt/amadeus/fg8/Backup/grafana";
    group = "labmembers";
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 04:30:00" ]; # weekly at 0330 Sun
    blacklist = [
      "/conf"
      "/tools"
    ]; # they're symlinks into nix store
  };

  # To handle SSL
  security.acme = {
    acceptTerms = true;
    defaults.email = "natha"+"nda"+"vis"+"199"+"9"+"@g"+"mail"+".com"; # maybe avoid some automated spam
  };
  services.nginx =
    let
      localDomain = "fglab";
      tailnet = "time-augmented.ts.net";
      vcu = "vcu.${localDomain}";
      zwei = "zwei.${localDomain}";
      zweiTail = "zwei.${tailnet}";
      toUrl = domain: port: "http://${domain}:${toString port}";
    in
    {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      # Increased to avoid warnings
      serverNamesHashBucketSize = 1024;
      serverNamesHashMaxSize = 128;

      virtualHosts."_" = {
        default = true;
        rejectSSL = true;
        locations."/".return = "444"; # silently reject
      };

      virtualHosts."zwei.${localDomain}" = {
        serverAliases = [ zweiTail "127.0.0.1" "localhost" ];
        extraConfig = ''
          allow 192.168.10.0/24; # lan
          allow 100.64.0.0/10; # tailnet
          allow fd7a:115c:a1e0::/48; # tailnet v6
          allow 127.0.0.1; # loopback
          deny all;
        '';
        locations =
          let
            arrConfig = service: port: {
              "/${service}" = {
                proxyPass = toUrl vcu port;
                proxyWebsockets = true;
              };
              "${if service == "prowlarr" then "~ ^/prowlarr(/[0-9]+)?/api" else "/${service}/api"}" = {
                proxyPass = toUrl vcu port;
                extraConfig = "auth_basic off;";
              };
            };
            arrServices =
              { }
              // (arrConfig "sonarr" 8989)
              // (arrConfig "radarr" 7878)
              // (arrConfig "lidarr" 8686)
              // (arrConfig "readarr" 8787)
              // (arrConfig "prowlarr" 9696);
          in
          arrServices
          // {
            "/heartbeat" = {
              return = "200 \"ok\"";
              extraConfig = "add_header Content-Type text/plain;";
            };
            "/" = {
              root = pkgs.writeTextDir "index.html" (builtins.readFile ./dashboard.html);
            };
            "/grafana" =
              let
                grafanaUrl = toUrl zwei config.services.grafana.settings.server.http_port;
              in
              {
                proxyPass = "${grafanaUrl}";
                proxyWebsockets = true;
              };
            "/grafana/api/live" =
              let
                grafanaUrl = toUrl zwei config.services.grafana.settings.server.http_port;
              in
              {
                proxyPass = "${grafanaUrl}";
                proxyWebsockets = true;

              };
            "/plex" = {
              proxyPass = toUrl vcu 32400;
              proxyWebsockets = true;
              extraConfig = ''
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
            "/jellyfin" = {
              proxyPass = toUrl zwei 8096;
              proxyWebsockets = true;
            };
            "/transmission" = {
              proxyPass = toUrl vcu 9091;
              proxyWebsockets = true;
              extraConfig = ''
                proxy_pass_header  X-Transmission-Session-Id;
                proxy_read_timeout 300;
              '';
            };
            "/kavita" = {
              return = "301 $scheme://$host/kavita/";
            };
            "/kavita/" = {
              proxyPass = toUrl zwei config.services.kavita.settings.Port;
              proxyWebsockets = true;
              extraConfig = ''
                # Stop Kavita from compressing HTML so Nginx can read it
                proxy_set_header Accept-Encoding "";

                # Force rewrite the base href that is stuck in the Nix store
                sub_filter 'href="/"' 'href="/kavita/"';
                sub_filter_once on;
              '';
            };
            "/audiobookshelf" = {
              proxyPass = toUrl zwei config.services.audiobookshelf.port;
              proxyWebsockets = true;
            };
          };
      };
      virtualHosts."immich.zwei.${localDomain}" = {
        serverAliases = [ "immich.zwei.${tailnet}" ];
        extraConfig = ''
          allow 192.168.10.0/24; # lan
          allow 100.64.0.0/10; # tailnet
          allow fd7a:115c:a1e0::/48; # tailnet v6
          allow 127.0.0.1; # loopback
          deny all;

          client_max_body_size 50000M;
          proxy_request_buffering off;
          client_body_buffer_size 1024k;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout 600s;
        '';
        locations."/" = {
          proxyPass = toUrl "zwei.${localDomain}" config.services.immich.port;
          proxyWebsockets = true;
        };
      };

      virtualHosts."id.${publicDomain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = toUrl zwei 1411;
          proxyWebsockets = true;
        };
      };
      virtualHosts."immich.${publicDomain}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_request_buffering off;
          client_body_buffer_size 1024k;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout 600s;
        '';

        locations."/" = {
          proxyPass = toUrl "zwei.${localDomain}" config.services.immich.port;
          proxyWebsockets = true;
        };
      };
      virtualHosts."kavita.${publicDomain}" = let
        kavitaPort = config.services.kavita.settings.Port;
      in {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          return = 403;
        };
        locations."/kavita/api/opds" = { # KOReader sync
          proxyPass = toUrl "zwei.${localDomain}" kavitaPort;
          proxyWebsockets = true;
        };
        locations."/kavita/api/images" = { # chapter images etc
          proxyPass = toUrl "zwei.${localDomain}" kavitaPort;
        };
        locations."/kavita/api/books" = { # book downloads (maybe check if needed)
          proxyPass = toUrl "zwei.${localDomain}" kavitaPort;
        };
      };
      virtualHosts."audiobookshelf.${publicDomain}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          client_max_body_size 10240M;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout 600s;
        '';
        locations."/" = {
          proxyPass = toUrl zwei config.services.audiobookshelf.port;
          proxyWebsockets = true;
        };
      };
    };
}
