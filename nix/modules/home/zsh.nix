{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nd0.home.zsh;
  shellAliases = (import ../values.nix { }).shellAliases;
  themeFile = ./../../../config/oh-my-zsh/custom/my_kphoen.zsh-theme;
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

      shellAliases = shellAliases;

      initExtra = ''
        source "${themeFile}"

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

    };
  };
}
