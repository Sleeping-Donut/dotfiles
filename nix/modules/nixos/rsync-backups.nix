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

				whitelist = lib.mkOption {
					description = "Paths you explicitly want to copied, all others will get ignored";
					type = lib.types.listOf lib.types.str;
					default = [];
				};

				parallelism = lib.mkOption {
					description = "";
					type = lib.types.int;
					default = 1;
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
		isNullOrEmpty = v: v == null || ((lib.isString v) && v == "") || ((lib.isList v) && builtins.length v == 0);

		# for each target make the service and timer containing the config passed in builder
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
	in {
		systemd.services = forAllTargets "rsync-backup" (target: targetCfg:
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
					# --numeric-ids 
					Type = "oneshot";
					ExecStart = let
						# rsync and parallel command construction
						rsyncDeleteFlag = if targetCfg.pruneRemote then "--delete" else "";

						whitelistFile = builtins.toFile "rsync-includes" (builtins.concatStringsSep "\n" targetCfg.whitelist);
						whitelist = if (isNullOrEmpty targetCfg.whitelist) then "" else "--include-from='${whitelistFile}' --exclude='*'";

						rsyncCmd = src: extraOpts: ''
							${lib.getExe targetCfg.package} \
								-rlt \
								${extraOpts} \
								--no-perms \
								--chmod=ugo=rwX \
								--chown=:labmembers \
								--omit-dir-times \
								--partial \
								${whitelist} \
								${rsyncDeleteFlag} \
								'${src}' \
								'${targetCfg.destDir}/'
						'';
						singleCmd = rsyncCmd "${targetCfg.sourceDir}/" "";
						parallelCmd = ''
							${rsyncCmd targetCfg.sourceDir "--dry-run -v --info=name1"} \
							| ${lib.getExe pkgs.parallel} \
								-j ${builtins.toString targetCfg.parallelism} \
								--lb \
								"${rsyncCmd (targetCfg.sourceDir + "/") "--files-from=-"}"
						'';

						fullCmdScript = pkgs.writeShellScriptBin "rsync-script-${target}" (if (targetCfg.parallelism < 2) then singleCmd else parallelCmd);
					in [
						# make dir then run the constructed rsync command
						"mkdir -p '${targetCfg.destDir}/'"
						(toString fullCmdScript)
					];
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

