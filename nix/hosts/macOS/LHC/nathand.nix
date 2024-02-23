{ pkgs, pkgs-unstable, home-modules, ... }:
{
	imports = [
		home-modules.firefox
		home-modules.neovim
		home-modules.zsh
		home-modules.shell-profile
		home-modules.tealdeer
		home-modules.tmux
	];

	home.stateVersion = "23.11";
	home.file.".hushlogin".text = "";

	nd0.home = {
		firefox.enable = true;
		neovim.enable = true;
		shell-profile = { enable = true; symlink.enable = false; };
		tealdeer.enable = true;
		tmux.enable = true;
		zsh.enable = true;
	};

	home.packages = let
		stable = with pkgs; [];
		unstable = with pkgs-unstable; [ yt-dlp];
	in
		stable ++ unstable;

	programs = {
		bat.enable = true;
		ripgrep.enable = true;
		fzf = { enable = true; enableZshIntegration = true; enableBashIntegration = true; };
	};
}
