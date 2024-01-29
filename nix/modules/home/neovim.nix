{ options, config, lib, pkgs, ... }:
with lib;
let
	cfg = config.nd0.home.neovim;
in
{
	options.nd0.home.neovim = {
		enable = mkEnableOption "Whether to install neovim in home";
		bare = mkBoolOpt false "Whether to do bare install";
	};

	config = mkIf cfg.enable {
		programs.neovim = {
			enable = true;
		};
		home.file."nvim" = mkIf (!bare) {
			source = ../../config/nvim;
			target = ".config/nvim";
		};
	};
}
