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
    alias dotpull='cd ~/dotfiles \
      && echo "Pulling ~/dotfiles" && git pull \
      && cd - > /dev/null'
    alias nixup='nh os switch -H zwei ~/dotfiles'
    softreboot() {
      local kernel="$(readlink -f /run/booted-system/kernel)"
      local initrd="$(readlink -f /run/booted-system/initrd)"
      local cmdline="$(cat /proc/cmdline)"
      echo "Loading $kernel ..."
      sudo kexec -l "$kernel" --initrd="$initrd" --command-line="$cmdline"
      echo "Executing kexec ..."
      sudo kexec -e
    }
    softreboot-next() {
      local kernel="$(readlink -f /run/current-system/kernel)"
      local initrd="$(readlink -f /run/current-system/initrd)"
      local cmdline="$(cat /proc/cmdline)"
      echo "Loading $kernel ..."
      sudo kexec -l "$kernel" --initrd="$initrd" --command-line="$cmdline"
      echo "Executing kexec ..."
      sudo kexec -e
    }
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
