{ pkgs, pkgs-unstable, inputs, home-modules, darwin-home-modules, ... }:
{
	imports = [
		inputs.nur.hmModules.nur

		home-modules.firefox
		home-modules.neovim
		home-modules.zsh
		home-modules.shell-profile
		home-modules.tealdeer
		home-modules.tmux
		home-modules.ata-conf
		home-modules.bins

		darwin-home-modules.alacritty-conf
	];

	home.stateVersion = "23.11";
	home.file.".hushlogin".text = "";

	# TODO: Need to copy .profile-prefs to $HOME
	# NOTE: only copy if file does not exists

	nd0.home = {
		alacritty-conf.enable = true;
		ata-conf.enable = true;
		bins.enable = true;
		firefox.enable = true;
		neovim = { enable = true; lsps = true; formatters = true; };
		shell-profile = { enable = true; symlink.enable = true; };
		tealdeer.enable = true;
		tmux.enable = true;
		zsh.enable = true;
	};

	home.packages = let
		stable = with pkgs; [];
		unstable = with pkgs-unstable; [
			fd
			gifski
			iina
			raycast
			yt-dlp
		];
	in
		stable ++ unstable;

	programs = {
		git.enable = true;
		bat.enable = true; 
		eza = { enable = true; package = pkgs-unstable.eza; };
		fzf = { enable = true; package = pkgs-unstable.fzf; enableZshIntegration = true; enableBashIntegration = true; };
		jq = { enable = true; package = pkgs-unstable.jq; };
		ripgrep = { enable = true; package = pkgs-unstable.ripgrep; };
		yt-dlp = { enable = true; package = pkgs-unstable.yt-dlp; };
		vscode = { enable = true; package = pkgs-unstable.vscode; };
	};
}
