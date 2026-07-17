{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.nd0.services.stump;
in
{
  options.nd0.services.stump = {
    enable = lib.mkEnableOption "stump, a comics, manga and digital book server";

    package = lib.mkOption {
      description = "Stump package to use";
      default = pkgs-unstable.stump;
      defaultText = lib.literalExpression "pkgs-unstable.stump";
      type = lib.types.package;
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/stump";
      description = "Directory for stump config and database.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 10001;
      description = "HTTP port stump listens on.";
    };

    environment = lib.mkOption {
      description = "Environment variables set directly on the service.";
      default = { };
      example = {
        STUMP_ALLOWED_ORIGINS = "https://stump.example.com";
        STUMP_OIDC_CLIENT_ID = "stump";
      };
      type = lib.types.attrsOf lib.types.str;
    };

    secretFiles = lib.mkOption {
      description = "Environment variables loaded from files at runtime via systemd LoadCredential. The file path is mapped into an ephemeral ramfs ($CREDENTIALS_DIRECTORY) at service start.";
      default = { };
      example = {
        STUMP_OIDC_CLIENT_SECRET = "/opt/stump/oidc-client-secret";
      };
      type = lib.types.attrsOf lib.types.path;
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open port in firewall for stump.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "stump";
      description = "User account under which stump runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "stump";
      description = "Group under which stump runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."10-stump".${cfg.dataDir}.d = {
      user = cfg.user;
      group = cfg.group;
      mode = "0700";
    };

    systemd.services.stump = {
      description = "Stump - Comics, Manga, and Digital Book Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/stump") "stump";
        ReadWritePaths = lib.mkIf (cfg.dataDir != "/var/lib/stump") [ cfg.dataDir ];
        SyslogIdentifier = "stump";
        Restart = "on-failure";
        RestartSec = "10s";

        LoadCredential = lib.mapAttrsToList (name: path: "${name}:${toString path}") cfg.secretFiles;

        PrivateTmp = true;
        RemoveIPC = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = [""];
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      };

      environment = {
        STUMP_CONFIG_DIR = "${cfg.dataDir}/config";
        STUMP_PORT = toString cfg.port;
      } // cfg.environment;

      script = ''
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _:
          "export ${name}=$(cat \"$CREDENTIALS_DIRECTORY/${name}\")"
        ) cfg.secretFiles)}
        exec ${lib.getExe cfg.package}
      '';
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    users.users = lib.mkIf (cfg.user == "stump") {
      stump = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };
    };

    users.groups = lib.mkIf (cfg.group == "stump") {
      stump = { };
    };
  };
}
