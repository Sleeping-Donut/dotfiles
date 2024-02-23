{ pkgs, nur, home-modules, ... }:
{
	imports = [
		home-modules.neovim
		home-modules.zsh
		home-modules.shell-profile
		home-modules.tmux
	];

	home.stateVersion = "23.11";
	home.file.".hushlogin".text = "";

	nd0.home = {
		neovim.enable = true;
		shell-profile = { enable = true; symlink.enable = false; };
		tmux.enable = true;
		zsh.enable = true;
	};

	programs = {
		bat.enable = true;
		ripgrep.enable = true;
	};
}
