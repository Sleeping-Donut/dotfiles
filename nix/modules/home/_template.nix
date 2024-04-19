{ lib, config, pgks, pkgs-unstable, ... }:
let
	cfg = config.nd0.home.PROGRAM;
in
{
	options.nd0.home.PROGRAM = {
		enable = lib.mkEnableOption "Whether to enable PROGRAM";
	};
	cfg = lib.mkIf {
		# PROGRAM CONFIG HERE
	};
}
