{ pkgs, nur, home-modules, ... }:
{
	imports = [
		home-modules.neovim
		home-modules.zsh
		home-modules.tmux
	];
	home.stateVersion = "23.11";
	home.file.".hushlogin".text = "";
#	home.file."printresult.txt".text = "${./testfile.nix}";

	nd0.home = {
		neovim.enable = true;
		tmux.enable = true;
		zsh.enable = true;
	};
}
