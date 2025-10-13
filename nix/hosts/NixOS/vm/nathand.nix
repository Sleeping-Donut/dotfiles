{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:
{
  home.stateVersion = "23.11";

  home.file.".profile".text = ''
    export PATH="$PATH:$HOME/.local/bin"
  '';

  home.packages = with pkgs-unstable; [
    bat
    btop
  ];
}
