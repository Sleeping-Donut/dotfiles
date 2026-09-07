{
  lib,
  config,
  pkgs,
  system,
  pkgs-unstable,
  inputs,
  sources,
  modules,
  ...
}:
{
  home.stateVersion = "23.11";

  home.file.".profile".text = ''
    export PATH="$PATH:$HOME/.local/bin"
  '';

  home.file.".local/bin/softreboot".source = ../../../../local/bin/softreboot;
  home.file.".local/bin/softreboot-next".source = ../../../../local/bin/softreboot-next;

  home.packages = with pkgs-unstable; [
    bat
    btop
    ripgrep
    speedtest-go
    systemctl-tui
    traceroute
    mpv
    nix-search-cli
    vlc
  ];
}
