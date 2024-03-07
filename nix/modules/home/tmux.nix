{ lib, pkgs, config, ... }:
let
	cfg = config.nd0.home.tmux;
in
{
	options.nd0.home.tmux = {
		enable = lib.mkEnableOption "Whether to install tmux in home";
	};

	config = lib.mkIf cfg.enable {
		programs.tmux = {
			enable = true;
		};
		home.file.".config/tmux".source = ../../../config/tmux;
		home.file.".local/bin/tmux-sessionizer".source = ../../../local/bin/tmux-sessionizer;
	};
}
