{ lib, pkgs, config, ... }:
let
	cfg = config.nd0.home.neovim;
#	cfg = config.nd0.home.neovim;
in
{
	options.nd0.home.neovim = {
#	options.nd0.home.neovim = {
		enable = lib.mkEnableOption "Whether to install neovim in home";
		cop = lib.mkOption {
			type = lib.types.bool;
			default = true;
			description = "Whether to do bare install";
		};
	};

	config = lib.mkIf cfg.enable {
		programs.neovim = {
			enable = true;
		};
		home.file.".config/nvim" =
#		mkIf cfg.cop
		{
			source = ../../../config/nvim;
			target = ".config/nvim";
		};
	};
}
