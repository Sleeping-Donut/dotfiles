{ lib, pkgs, pkgs-unstable, config, ... }:
let
	cfg = config.nd0.home.alacritty;
in
{
	options.nd0.home.alacritty = {
		enable = lib.mkEnableOption "Whether to install alacritty in home";
	};

	config = lib.mkIf cfg.enable {
		# Install with homebrew
		xdg.configFile."alacritty" = 
		{
			source = ../../../../config/alacritty;
		#	target = "alacritty";
		};
	};
}
