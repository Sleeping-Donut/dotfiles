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
  keys = import modules.common.keys;
in
{
  imports = [
    ./hardware-configuration.nix
    (repo-root + "/nix/modules/nixos/rclone-backups.nix")
    (repo-root + "/nix/modules/nixos/stump.nix")
    ./services/kavita.nix
    ./services/stump.nix
    ./services/plex.nix
    ./services/jellyfin.nix
    ./services/immich.nix
    ./services/audiobookshelf.nix
    ./services/pocket-id.nix
    ./services/grafana.nix
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

  systemd.tmpfiles.settings."10-fg8-local" = let
    lockedDown = { mode = "0700"; user = "root"; group = "root"; };
  in {
    "/mnt/amadeus/fg8/Backup".d = lockedDown;
    "/mnt/amadeus/fg8/Media".d = lockedDown;
    "/mnt/amadeus/fg8/Pending".d = lockedDown;
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

  services.unifi = {
    enable = false;
    maximumJavaHeapSize = 2048;
    openFirewall = true;
    unifiPackage = pkgs-unstable.unifi;
    mongodbPackage = pkgs.mongodb-ce;
    # Files have to be in `/var/lib/unifi` (╥‸╥)
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

  # To handle SSL
  security.acme = {
    acceptTerms = true;
    defaults.email = "natha"+"nda"+"vis"+"199"+"9"+"@g"+"mail"+".com"; # maybe avoid some automated spam
  };
  services.nginx =
    let
      inherit (import ./net-helpers.nix) localDomain tailnet vcu zwei zweiTail localACLs toUrl;
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
        extraConfig = localACLs;
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
            "/health" = {
              proxyPass = "http://127.0.0.1:8083";
              extraConfig = ''
                proxy_buffering off;
                proxy_cache off;
              '';
            };
            "/transmission" = {
              proxyPass = toUrl vcu 9091;
              proxyWebsockets = true;
              extraConfig = ''
                proxy_pass_header  X-Transmission-Session-Id;
                proxy_read_timeout 300;
              '';
            };
          };
      };
    };
}
