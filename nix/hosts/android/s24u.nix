{
  config,
  pkgs,
  lib,
  system,
  pkgs-unstable,
  hostname ? "s24u",
  inputs,
  sources,
  modules,
  ...
}:
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
    ripgrep
    wget
  ];

  home-manager.config = { pkgs, ... }: {
    imports = [
      modules.home.neovim
      modules.home.zsh
      modules.home.shell-profile
      modules.home.tealdeer
      modules.home.tmux
    ];

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
      zsh.enable = true;
    };
  };
}
