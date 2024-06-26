{ lib, pkgs, pkgs-unstable, config, ... }:
let
	cfg = config.nd0.home.alacritty-conf;
in
{
	options.nd0.home.alacritty-conf = {
		enable = lib.mkEnableOption "Whether to install alacritty in home";
	};

	config = lib.mkIf cfg.enable {
		# Install with homebrew
		xdg.configFile."alacritty/alacritty_REF.toml".source = ../../../../config/alacritty/alacritty.toml;
	};
}
