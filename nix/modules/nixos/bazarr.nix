{ config, pkgs, lib, ... }:
let
  cfg = config.nd0.services.bazarr;
in
{
  options = {
    nd0.services.bazarr = {
      enable = lib.mkEnableOption "bazarr, a subtitle manager for Sonarr and Radarr";

      package = lib.mkOption {
        description = "";
        default = pkgs.bazarr;
        defaultText = lib.literalExpression "pkgs.bazarr";
        example = lib.literalExpression "pkgs.bazarr";
        type = lib.types.package;
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        description = "The directory where Bazarr stores its data files.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open ports in the firewall for the bazarr web interface.";
      };

      listenPort = lib.mkOption {
        type = lib.types.port;
        default = 6767;
        description = "Port on which the bazarr web interface should listen";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "bazarr";
        description = "User account under which bazarr runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "bazarr";
        description = "Group under which bazarr runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
		systemd.tmpfiles.settings."10-bazarr".${cfg.dataDir}.d = {
		inherit (cfg) user group;
		mode = "0700";
	};

    systemd.services.bazarr = {
      description = "bazarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = rec {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/bazarr") "bazarr";
        ReadWritePaths = lib.mkIf (cfg.dataDir != "/var/lib/bazarr") cfg.dataDir;
        SyslogIdentifier = "bazarr";
        ExecStart = pkgs.writeShellScript "start-bazarr" ''
          ${cfg.package}/bin/bazarr \
            --config "${cfg.dataDir}" \
            --port ${toString cfg.listenPort} \
            --no-update True
        '';
        Restart = "on-failure";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listenPort ];
    };

    users.users = lib.mkIf (cfg.user == "bazarr") {
      bazarr = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };
    };

    users.groups = lib.mkIf (cfg.group == "bazarr") {
      bazarr = {};
    };
  };
}

