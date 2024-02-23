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
	
	programs.tmux.enable = true;

	nd0.home = {
		neovim.enable = true;
		shell-profile = { enable = true; symlink = false; };
#		tmux.enable = true;
		zsh.enable = true;
	};
}
