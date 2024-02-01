{ lib, pkgs, config, ... }:
with lib;
let
	cfg = config.nd0.neovim;
#	cfg = config.nd0.home.neovim;
in
{
	options.nd0.neovim = {
#	options.nd0.home.neovim = {
		enable = mkEnableOption "Whether to install neovim in home";
		cop = mkOption {
			type = types.bool;
			default = true;
			description = "Whether to do bare install";
		};
	};

	config = mkIf cfg.enable {
		programs.neovim = {
			enable = true;
		};
		home.file."nvim" = 
#		mkIf cfg.cop
		{
			source = ../../config/nvim;
			target = ".config/nvim";
		};
	};
}
