{
  config,
  lib,
  pkgs,
  pkgs-unstable,
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
    ripgrep
    wget
  ];
}
