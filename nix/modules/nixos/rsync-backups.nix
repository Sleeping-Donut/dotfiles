{ config, pkgs, lib, ... }:
let
	cfg = config.nd0.rsync-backups;
in
{
	options.nd0.rsync-backups = lib.mkOption {
		description = "Attribute set of backup targets";
		default = {};
		type = lib.types.attrsOf (lib.types.submodule {
			options = {
				enable = lib.mkEnableOption "Rsync service and timer for a backup";

				sourceDir = lib.mkOption {
					description = "Directory that you want archived excluding trailing slash";
					type = lib.types.str;
				};

				destDir = lib.mkOption {
					description = "Directory you want to the archived directory to go excluding trailing slash";
					type = lib.types.str;
				};

				user = lib.mkOption {
					description = "User account under which rsync runs";
					default = null;
					type = lib.types.nullOr lib.types.str;
				};

				group = lib.mkOption {
					description = "Group account under which rsync runs";
					default = null;
					type = lib.types.nullOr lib.types.str;
				};

				pruneRemote = lib.mkEnableOption "Include `--delete` flag when running rsync";

				OnCalendar = lib.mkOption {
					description = "systemd OnCalendar (string or list)";
					type = lib.types.nonEmptyListOf lib.types.str;
					example = [ "Sun *-*-* 03:00:00" ];
					#TODO: add validation fn
				};

				Persistent = lib.mkOption {
					description = "Run job on next boot if missed scheduled run";
					type = lib.types.bool;
					default = true;
				};

				package = lib.mkOption {
					description = "Package providing rsync";
					type = lib.types.package;
					default = pkgs.rsync;
				};
			};
		});
	};

	config = let
		forAllTargets = (namePrefix: builder: lib.foldl'
			(acc: pair:
				# either:
					# rsync-backup-TARGET = { service stuff here }
					# rsync-backup-timer-TARGET = { timer stuff here }
				acc // { "${namePrefix}-${pair.name}" = (builder pair.name pair.value); }
			)
			{}
			(lib.attrsToList cfg)
		);
		isNullorBlank = v: v == null || ((lib.isString v) && v == "");
	in {
		systemd.services = forAllTargets "rsync-backup" (target: targetCfg:
			lib.mkIf targetCfg.enable {
				description = "Rsync backup for ${target}";
				wants = [ "remote-fs.target" ];
				after = [ "remote-fs.target" ];
				wantedBy = [ "multi-user.target" ];
				serviceConfig = let
					# Handle group and user like this because akward mkIf only outputs attrsets
					userConfig = if (!isNullorBlank targetCfg.user) then { User = targetCfg.user; } else {};
					groupConfig = if (!isNullorBlank targetCfg.group) then { Group = targetCfg.group; } else {};

					optionalConfigs = userConfig // groupConfig;
					rsyncDeleteFlag = if targetCfg.pruneRemote then "--delete" else "";
				in {
					Type = "oneshot";
					ExecStart = ''
						${lib.getExe targetCfg.package} -rl --no-perms --chmod=Du+rwx,Dg+rwx,Fu+rw,Fg+rw,Dg+s --chown=:labmembers --omit-dir-times --partial ${rsyncDeleteFlag} '${targetCfg.sourceDir}/' '${targetCfg.destDir}/'
					'';
				} // optionalConfigs;
			}
		);

		systemd.timers = forAllTargets "rsync-backup-timer" (target: targetCfg:
			lib.mkIf targetCfg.enable {
				description = "Timer for rsync backup of ${target}";
				wantedBy = [ "timers.target" ];
				timerConfig.OnCalendar = targetCfg.OnCalendar;
				timerConfig.Persistent = targetCfg.Persistent;
				wants = [ "rsync-backup-${target}.service" ];
			}
		);
	};
}

