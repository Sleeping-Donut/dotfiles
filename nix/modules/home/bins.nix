{ lib, config, pgks, pkgs-unstable, ... }:
let
	cfg = config.nd0.home.bins;
in
{
	options.nd0.home.bins = {
		enable = lib.mkEnableOption "Whether to copy the binaries for local bin";
	};
	cfg = lib.mkIf {
		# xdg local etc etc
		home.file.".local/bin/batterylvl".source = ../../../local/bin/batterylvl;
		home.file.".local/bin/print-clrs".source = ../../../local/bin/print-clrs;
	};
}
