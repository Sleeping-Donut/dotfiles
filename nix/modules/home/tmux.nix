{ lib, pkgs, config, ... }:
let
	cfg = config.nd0.home.tmux;
in
{
	options.nd0.home.tmux = {
#	options.nd0.home.neovim = {
		enable = lib.mkEnableOption "Whether to install tmux in home";
	};

	config = lib.mkIf cfg.enable {
		programs.tmux = {
			enable = true;
		};
		home.file.".config/tmux" = 
#		mkIf cfg.cop
		{
			source = ../../../config/tmux;
		};
	};
}
