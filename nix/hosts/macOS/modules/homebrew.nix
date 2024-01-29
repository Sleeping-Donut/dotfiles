{ options, config, lib, pkgs, nix-homebrew, ... }:
with lib;
let
	cfg = config.nd0.macOS.hombrew;
in
{
	options.nd0.macOS.homebrew = with types; {
		enable = mkEnableOption "Whether to enable homebrew";
		user = mkOption {
			type = str;
			description = "The user owning the homebrew install";
		};
		autoMigrate = mkBoolOpt false "Whether to enable auto migration of existing homebrew install";
		enableRosetta = mkEnableOption "Whether to enable Rosetta for homebrew";
	};

	config = mkIf cfg.enable {

		home-manager = {
			enable = true;
			user = cfg.user;
			enableRosetta = cfg.enableRosetta;
		};
	};
}
