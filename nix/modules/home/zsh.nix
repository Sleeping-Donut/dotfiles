{ lib, pkgs, config, ... }:
let
	cfg = config.nd0.home.zsh;
	shellAliases = (import ../values.nix {}).shellAliases;
in
{
	options.nd0.home.zsh = {
		enable = lib.mkEnableOption "Whether to install zsh in home";
	};

	config = lib.mkIf cfg.enable {
		programs.zsh = {
			enable = true;
			autosuggestion.enable = true;
#			enableSyntaxHighlighting = true; # DEPRICATED
			syntaxHighlighting.enable = true;
			history.size = 10000;

			oh-my-zsh = {
				enable = true;
				plugins = [ "git" ];
				theme = "kphoen";
			#	custom = "$HOME/.config/oh-my-zsh/custom";
			};

			 shellAliases = shellAliases;

			oh-my-zsh.extraConfig = ''
			source "$HOME/.profile"

			# Nix
			if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
				source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
			fi
			# End Nix

			if [ command -v direnv &> /dev/null ]; then
				eval "$(direnv hook zsh)"
			fi
			'';
			# initExtras = ........

		};
	};
}
