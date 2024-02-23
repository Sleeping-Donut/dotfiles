{ lib, pkgs, config, ... }:
let
	cfg = config.nd0.home.shell-profile;
in
{
	options.nd0.home.shell-profile = {
		enable = lib.mkEnableOption "Whether to use the .profile from the repo";
		symlink.enable = lib.mkEnableOption "Whether to symlink the file";
	};

	config = lib.mkIf cfg.enable {
		home.file.".profile" = {
			source = ../../../home/.profile;
			target = lib.mkIf cfg.symlink.enable ".profile"
		};
	};
}
