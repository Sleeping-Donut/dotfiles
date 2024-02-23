{ lib, pkgs, config, ... }:
let
	cfg = config.nd0.home.tealdeer;
in
{
	options.nd0.home.tealdeer = {
		enable = lib.mkEnableOption "Whether to install tealdeer in home";
	};

	config = lib.mkIf cfg.enable {
		programs.tealdeer = {
			enable = true;
		};
		xdg.configFile."tealdeer" = 
#		mkIf cfg.cop
		{
			source = ../../../config/tealdeer;
			target = "tealdeer";
		};
	};
}
