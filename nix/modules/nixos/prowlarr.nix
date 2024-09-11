{ config, pkgs, lib, ... }:

with lib;

let
	cfg = config.services.nd0-prowlarr;

in
{
	options = {
		services.nd0-prowlarr = {
			enable = mkEnableOption "Prowlarr, an indexer manager/proxy for Torrent trackers and Usenet indexers";

			package = mkPackageOption pkgs "prowlarr" { };

			dataDir = mkOption {
				type = types.str;
				default = "/var/lib/prowlarr/.config/Prowlarr";
				description = "The directory where Prowlarr stores its data files.";
			};

			openFirewall = mkOption {
				type = types.bool;
				default = false;
				description = "Open ports in the firewall for the Prowlarr web interface.";
			};

			user = mkOption {
				type = types.str;
				default = "prowlarr";
				description = "User account under which Prowlarr runs.";
			};

			group = mkOption {
				type = types.str;
				default = "prowlarr";
				description = "Group under which Prowlarr runs.";
			};
		};
	};

	config = mkIf cfg.enable {
		systemd.tmpfiles.settings."10-prowlarr".${cfg.dataDir}.d = {
			inherit (cfg) user group;
			mode = "0700";
		};

		systemd.services.prowlarr = {
			description = "Prowlarr";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];

			serviceConfig = {
				Type = "simple";
				User = cfg.user;
				Group = cfg.group;
				StateDirectory = "prowlarr";
				ExecStart = "${lib.getExe cfg.package} -nobrowser -data='${cfg.dataDir}'";
				Restart = "on-failure";
			};
		};

		networking.firewall = mkIf cfg.openFirewall {
			allowedTCPPorts = [ 9696 ];
		};

		users.users = mkIf (cfg.user == "prowlarr") {
			prowlarr = {
				description = "Prowlarr service";
				group = cfg.group;
				home = cfg.dataDir;
				isSystemUser = true;
			};
		};

		users.groups = mkIf (cfg.group == "prowlarr") {
			prowlarr = {};
		};
	};
}
