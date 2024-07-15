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

	home.packages = with pkgs-unstable; [
		age
		ansible
		btop
		chatgpt-cli
		ctop
		fastfetch
		fd
		gifski
		glow
		lazygit
		nix-output-monitor
		pkgs.gallery-dl
		speedtest-go
		speedtest-rs
		stow
		tokei
		tz
		utm
		yt-dlp
#		gobang
#		twitch-tui
	];

	programs = {
		bat.enable = true; 
		gh = { enable = true; package = pkgs-unstable.gh; settings = {
			editor = "nvim";
			git_protocol = "ssh";
		};};
		eza = { enable = true; package = pkgs-unstable.eza; };
		fzf = { enable = true; package = pkgs-unstable.fzf; enableZshIntegration = true; enableBashIntegration = true; };
		git.enable = true;
		jq = { enable = true; package = pkgs-unstable.jq; };
		ripgrep = { enable = true; package = pkgs-unstable.ripgrep; };
		vscode = { enable = true; package = pkgs-unstable.vscode; };
		yt-dlp = { enable = true; package = pkgs-unstable.yt-dlp; };
		zellij = { enable = true; package = pkgs-unstable.zellij; };
	};
}
