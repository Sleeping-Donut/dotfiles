{ config, pkgs, lib, ... }:
let
  cfg = config.nd0.services.lazylibrarian;
in
{
  options = {
    nd0.services.lazylibrarian = {
      enable = lib.mkEnableOption "LazyLibrarian, an ebook/audiobook/magazine manager";

      package = lib.mkOption {
        description = "LazyLibrarian package to use";
        default = pkgs.lazylibrarian;
        defaultText = lib.literalExpression "pkgs.lazylibrarian";
        type = lib.types.package;
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/lazylibrarian";
        description = "Directory for LazyLibrarian config and data.";
      };

      listenPort = lib.mkOption {
        type = lib.types.port;
        default = 5299;
        description = "Port on which LazyLibrarian should listen";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open port in firewall for LazyLibrarian.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "lazylibrarian";
        description = "User account under which LazyLibrarian runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "lazylibrarian";
        description = "Group under which LazyLibrarian runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.settings."10-lazylibrarian".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    systemd.services.lazylibrarian = {
      description = "LazyLibrarian";
      after = [ "network.target" "remote-fs.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/lazylibrarian") "lazylibrarian";
        SyslogIdentifier = "lazylibrarian";
        ExecStart = "${lib.getExe cfg.package} --datadir ${cfg.dataDir} --port ${toString cfg.listenPort} --nolaunch";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listenPort ];
    };

    users.users = lib.mkIf (cfg.user == "lazylibrarian") {
      lazylibrarian = {
        isSystemUser = true;
        group = cfg.group;
        home = "/var/empty";
      };
    };

    users.groups = lib.mkIf (cfg.group == "lazylibrarian") {
      lazylibrarian = { };
    };
  };
}
