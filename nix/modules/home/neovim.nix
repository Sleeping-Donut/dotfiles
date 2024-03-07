{ lib, pkgs, pkgs-unstable, config, ... }:
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
		lsps = lib.mkEnableOption "Whether to install LSPs";
	};

	config = lib.mkIf cfg.enable {
		programs.neovim = {
			enable = true;
			extraPackages = with pkgs-unstable; lib.mkIf cfg.lsps [
				ccls
				# csharp-ls # unsupported for darwin
				emmet-ls
				# fsautocomplete # unsupported for darwin
				gopls
				java-language-server
				kotlin-language-server
				lua-language-server
				luajitPackages.lua-lsp
				nil
				ocamlPackages.lsp
				python311Packages.python-lsp-server
				rnix-lsp
				rust-analyzer
				tailwindcss-language-server
				yaml-language-server

				rustfmt
				stylua
			];
		};
#		home.file.".config/nvim" = ;
		home.file.".config/nvim/init.lua" =
#		mkIf cfg.cop
		{
			source = ../../../config/nvim/init.lua;
#			target = ".config/nvim";
#			recursive = true;
		};
		home.file.".config/nvim/lua".source = ../../../config/nvim/lua;
		home.file.".config/nvim/lazy-lock.json".source =
			config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim/lazy-lock.json";
	};
}
