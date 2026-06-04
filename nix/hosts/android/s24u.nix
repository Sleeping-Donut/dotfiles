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

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  fonts.packages = with pkgs; [
    noto-fonts
  ];

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
