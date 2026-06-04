{
  config,
  pkgs,
  lib,
  system,
  pkgs-unstable,
  inputs,
  sources,
  modules,
  repo-root,
  ...
}:
let
  shellAliases = (import "${repo-root}/modules/values.nix" { }).shellAliases;
in
{
  system.stateVersion = "24.05";

  time.timeZone = "Europe/London";

  environment.etcBackupExtension = ".bak";
  environment.packages = with pkgs-unstable; [
    curl
    fd
    git
    neovim
    noto-fonts
    opencode
    ripgrep
    wget
  ];

  home-manager.config = { pkgs, ... }: {
    imports = [
      modules.home.neovim
      modules.home.shell-profile
      modules.home.tealdeer
      modules.home.tmux
    ];

    home.stateVersion = "24.05";

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      history.size = 10000;

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "kphoen";
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
    };

    nd0.home = {
      neovim = {
        enable = true;
        lsps = false;
        formatters = false;
      };
      shell-profile = {
        enable = true;
        symlink.enable = true;
      };
      tealdeer.enable = true;
      tmux.enable = true;
    };
  };
}
