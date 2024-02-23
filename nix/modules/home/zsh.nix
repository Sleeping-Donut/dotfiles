{ lib, pkgs, config, ... }:
let
	cfg = config.nd0.home.zsh;
	shellAliases = (import ../values.nix {}).shellAliases;
in
{
	options.nd0.home.zsh = {
#	options.nd0.home.neovim = {
		enable = lib.mkEnableOption "Whether to install zsh in home";
	};

	config = lib.mkIf cfg.enable {
		programs.zsh = {
			enable = true;
			enableAutosuggestions = true;
#			enableSyntaxHighlighting = true; # DEPRICATED
			syntaxHighlighting.enable = true;
			history.size = 10000;

			oh-my-zsh = {
				enable = true;
				plugins = [ "git" ];
				theme = "kphoen";
				# custom = "$HOME/.config/zsh_nix/custom";
			};

			 shellAliases = shellAliases;

			extraConfig = ''
			# Nix
			if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  				. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
			fi
			# End Nix
			'';
			# initExtras = ........

		};
	};
}
