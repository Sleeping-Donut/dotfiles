{ config, lib, ... }:
let
	cfg = config.nd0.home.testfile;
in
{
	options.nd0.home.testfile = {
		enable = lib.mkEnableOption "Whether to have testfile";
		text = lib.mkOption {
			type = lib.types.string;
			default = "";
			description = "What text to have in file";
		};
	};

	config = lib.mkIf cfg.enable {
		home.file."testfile.txt" = cfg.text;
	};
}
