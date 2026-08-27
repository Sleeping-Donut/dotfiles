{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nd0.services.trek;
in
{
  options.nd0.services.trek = {
    enable = lib.mkEnableOption "TREK, a travel itinerary and boarding pass manager";

    package = lib.mkOption {
      description = "TREK package to use";
      default = pkgs.callPackage ../../pkgs/trek.nix { };
      type = lib.types.package;
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/trek";
      description = "Directory for TREK config and database.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "HTTP port TREK listens on.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open port in firewall for TREK.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "trek";
      description = "User account under which TREK runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "trek";
      description = "Group under which TREK runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."10-trek".${cfg.dataDir}.d = {
      user = cfg.user;
      group = cfg.group;
      mode = "0700";
    };

    systemd.services.trek = {
      description = "TREK - Travel Itinerary and Boarding Pass Manager";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/trek") "trek";
        ReadWritePaths = lib.mkIf (cfg.dataDir != "/var/lib/trek") [ cfg.dataDir ];
        SyslogIdentifier = "trek";
        Restart = "on-failure";
        RestartSec = "10s";
        WorkingDirectory = "${cfg.package}/lib/node_modules/trek/server";
        ExecStart = "${lib.getExe cfg.package}";

        PrivateTmp = true;
        RemoveIPC = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = [ "" ];
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        LockPersonality = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      };

      environment = {
        NODE_ENV = "production";
        PORT = toString cfg.port;
        XDG_CACHE_HOME = "${cfg.dataDir}/cache";
        QT_QPA_PLATFORM = "offscreen";
      };

      preStart = ''
        mkdir -p ${cfg.dataDir}/cache
        mkdir -p ${cfg.dataDir}/logs
        mkdir -p ${cfg.dataDir}/uploads/files
        mkdir -p ${cfg.dataDir}/uploads/covers
        mkdir -p ${cfg.dataDir}/uploads/avatars
        mkdir -p ${cfg.dataDir}/uploads/photos
        chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
      '';
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    users.users = lib.mkIf (cfg.user == "trek") {
      trek = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };
    };

    users.groups = lib.mkIf (cfg.group == "trek") {
      trek = { };
    };
  };
}
