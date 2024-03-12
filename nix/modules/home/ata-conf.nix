{ lib, config, pgks, pkgs-unstable, ... }:
let
	cfg = config.nd0.home.ata-conf;
in
{
	options.nd0.home.ata-conf = {
		enable = lib.mkEnableOption "Whether to enable ata config";
	};
	config = lib.mkIf cfg.enable {
		xdg.configFile."ata/ata_REF.toml".source = ../../../config/ata/ata.toml;
	};
}
