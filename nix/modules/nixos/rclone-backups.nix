{ config, pkgs, lib, ... }:
let
	cfg = config.nd0.rclone-backups;
in
{
	options.nd0.rclone-backups = lib.mkOption {
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

				whitelist = lib.mkOption {
					description = "Paths you explicitly want to copied, all others will get ignored";
					type = lib.types.listOf lib.types.str;
					default = [];
				};

				transfers = lib.mkOption {
					description = "The number of file transfers to run in parallel";
					type = lib.types.int;
					default = 4; # to match rclone default
				};

				user = lib.mkOption {
					description = "User account under which rclone runs";
					default = null;
					type = lib.types.nullOr lib.types.str;
				};

				group = lib.mkOption {
					description = "Group account under which rclone runs";
					default = null;
					type = lib.types.nullOr lib.types.str;
				};

				pruneRemote = lib.mkEnableOption "Include `--delete` flag when running rclone";

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
					description = "Package providing rclone";
					type = lib.types.package;
					default = pkgs.rclone;
				};
			};
		});
	};

	config = let
		isNullOrEmpty = v: v == null || ((lib.isString v) && v == "") || ((lib.isList v) && builtins.length v == 0);

		# for each target make the service and timer containing the config passed in builder
		forAllTargets = (namePrefix: builder: lib.foldl'
			(acc: pair:
				# either:
					# rclone-backup-TARGET = { service stuff here }
					# rclone-backup-timer-TARGET = { timer stuff here }
				acc // { "${namePrefix}-${pair.name}" = (builder pair.name pair.value); }
			)
			{}
			(lib.attrsToList cfg)
		);
	in {
		systemd.services = forAllTargets "rclone-backup" (target: targetCfg:
			lib.mkIf targetCfg.enable {
				description = "Rsync backup for ${target}";
				wants = [ "remote-fs.target" ];
				after = [ "remote-fs.target" ];
				wantedBy = [ "multi-user.target" ];
				serviceConfig = let
					# Handle group and user like this because akward mkIf only outputs attrsets
					userConfig = if (isNullOrEmpty targetCfg.user) then {} else { User = targetCfg.user; };
					groupConfig = if (isNullOrEmpty targetCfg.group) then {} else { Group = targetCfg.group; };

					optionalConfigs = userConfig // groupConfig;
				in {
					Type = "oneshot";
					ExecStart = let
						# rclone and parallel command construction
						deleteFlag = if targetCfg.pruneRemote then "--delete-excluded" else "";
						copySync = if targetCfg.pruneRemote then "sync" else "copy";

						transfers = if targetCfg.transfers == 4 then "" else "--transfers ${builtins.toString targetCfg.transfers}";

						whitelistFile = builtins.toFile "rclone-whitelist" (let
							includeRules = builtins.map (item: "+ ${item}") targetCfg.whitelist;
							allRules = includeRules ++ [ "- **" ];
						in
							builtins.concatStringsSep "\n" allRules);
						whitelist = if (isNullOrEmpty targetCfg.whitelist) then "" else "--filter-from='${whitelistFile}'";

						rcloneScript = pkgs.writeShellScriptBin "rclone-script-${target}" ''
							${lib.getExe targetCfg.package} ${copySync} \
								'${targetCfg.sourceDir}/' \
								'${targetCfg.destDir}/' \
								${whitelist} \
								${deleteFlag} \
								${transfers} \
						'';
					in
						"${lib.getExe rcloneScript}"
					;
				} // optionalConfigs;
			}
		);

		systemd.timers = forAllTargets "rclone-backup-timer" (target: targetCfg:
			lib.mkIf targetCfg.enable {
				description = "Timer for rclone backup of ${target}";
				wantedBy = [ "timers.target" ];
				timerConfig.OnCalendar = targetCfg.OnCalendar;
				timerConfig.Persistent = targetCfg.Persistent;
				wants = [ "rclone-backup-${target}.service" ];
			}
		);
	};
}

