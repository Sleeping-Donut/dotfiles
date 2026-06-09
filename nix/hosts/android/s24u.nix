{
  config,
  pkgs,
  lib,
  system,
  pkgs-unstable,
  repo-root,
  inputs,
  sources,
  modules,
  ...
}:
let
  shellAliases = import modules.home.shell-aliases;
  neovim-nightly = (import inputs.nixpkgs-droid-compat {
    inherit system;
    overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
  }).neovim;
in
{
  system.stateVersion = "24.05";

  time.timeZone = "Europe/London";

  environment.etcBackupExtension = ".bak";
  environment.packages = with pkgs; [
    curl
    fd
    git
    nix-output-monitor
    noto-fonts
    pkgs-unstable.opencode
    pkgs-unstable.tealdeer
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
      syntaxHighlighting.enable = true;
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

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    programs.neovim.package = neovim-nightly;

    nd0.home = {
      neovim = {
        enable = true;
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
