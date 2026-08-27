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
            alias nixqueue='nh os boot -H vcu ~/dotfiles'
            softreboot() {
              local target_profile="/run/current-system"
              if [[ ! -d "$target_profile" ]]; then
                echo "Error: Profile directory ''${target_profile} does not exist." >&2
                return 1
              fi
              echo "Loading kexec image from current system (''${target_profile})..."
              sudo kexec -l "''${target_profile}/kernel" \
                --initrd="''${target_profile}/initrd" \
                --append="$(cat "''${target_profile}/kernel-params") init=''${target_profile}/init" || return 1
              echo "Triggering kexec reboot..."
              sudo systemctl kexec
            }
            softreboot-next() {
              local target_profile="''${1:-/nix/var/nix/profiles/system}"
              if [[ ! -d "$target_profile" ]]; then
                echo "Error: Profile directory ''${target_profile} does not exist." >&2
                return 1
              fi
              echo "Loading kexec image from ''${target_profile}..."
              sudo kexec -l "''${target_profile}/kernel" \
                --initrd="''${target_profile}/initrd" \
                --append="$(cat "''${target_profile}/kernel-params") init=''${target_profile}/init" || return 1
              echo "Triggering kexec reboot..."
              sudo systemctl kexec
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
