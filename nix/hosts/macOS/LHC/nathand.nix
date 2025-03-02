{ pkgs, pkgs-unstable, inputs, home-modules, darwin-home-modules, ... }:
{
	imports = [
		inputs.nur.modules.homeManager.default

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

	home.packages = with pkgs-unstable; [
		age
		ansible
		bottom
		btop
		chatgpt-cli
		ctop
		dust
		fastfetch
		fd
		gifski
		glow
		httpie
		jdk
		lazygit
		nix-output-monitor
		ollama
		pkgs.gallery-dl
		speedtest-go
		speedtest-rs
		starship
		stow
		# termscp
		tokei
		tz
		utm
		yt-dlp
#		gobang
#		twitch-tui
	];

	nd0.home = {
		alacritty-conf.enable = true;
		ata-conf.enable = true;
		bins.enable = true;
		firefox.enable = true;
		neovim = { enable = true; lsps = false; formatters = false; };
		shell-profile = { enable = true; symlink.enable = true; };
		tealdeer.enable = true;
		tmux.enable = true;
		zsh.enable = true;
	};

	programs = {
		bat.enable = true; 
		direnv = {
			enable = true;
			enableZshIntegration = true;
		};
		eza = { enable = true; package = pkgs-unstable.eza; };
		fzf = {
			enable = true;
			package = pkgs-unstable.fzf;
			enableZshIntegration = true;
			enableBashIntegration = true;
		};
		gh = {
			enable = true;
			package = pkgs-unstable.gh;
			settings = {
				editor = "nvim";
				git_protocol = "ssh";
			};
		};
		git.enable = true;
		jq = { enable = true; package = pkgs-unstable.jq; };
		ripgrep = { enable = true; package = pkgs-unstable.ripgrep; };
		yt-dlp = { enable = true; package = pkgs-unstable.yt-dlp; };
		zellij = { enable = true; package = pkgs-unstable.zellij; };
	};
}
