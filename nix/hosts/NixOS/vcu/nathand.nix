{
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
            alias dotpull='cd ~/dotfiles \
              && echo "Pulling ~/dotfiles" && git pull \
              && cd - > /dev/null'
            alias nixup='nh os switch -H vcu ~/dotfiles'
    	'';

  home.packages = with pkgs-unstable; [
    bat
    btop
    ripgrep
    speedtest-go
    systemctl-tui
    traceroute
  ];
}
