{
  lib,
  config,
  pkgs,
  system,
  pkgs-unstable,
  repo-root,
  inputs,
  sources,
  modules,
  ...
}:
{
  imports = [
    "${repo-root}/nix/modules/nixos/quadlets.nix"
  ];

  home.stateVersion = "23.11";

  home.file.".profile".text = ''
    		export PATH="$PATH:$HOME/.local/bin"
    	'';

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

  quadlets = {
    mullvad = {
      Unit = {
        Description = "Mullvad VPN Client Daemon";
        After = "network-online.target";
      };
      Container = {
        Image = pkgs.dockerTools.buildLayeredImage {
          name = "local/mullvad";
          tag = "latest";
          contents = with pkgs; [
            bash
            cacert       # Required to safely verify Mullvad API TLS certificates
            coreutils
            iproute2     # Required for managing network routes inside the namespace
            iptables     # Required by the daemon to isolate firewall rules
            mullvad      # Pulls the official mullvad-daemon and CLI binary
            tini         # Proper init for signal forwarding and zombie reaping
          ];
          config = {
            Entrypoint = [ "${lib.getExe pkgs.tini}" "--" ];
            Cmd = [
              (pkgs.writeShellScript "mullvad-entrypoint" ''
                export PATH="/bin:/sbin:$PATH"

                mkdir -p /var/lib/mullvad /etc/mullvad /var/log/mullvad

                trap 'kill $DAEMON_PID; wait $DAEMON_PID' TERM INT

                echo "Starting native Nix mullvad-daemon..."
                ${pkgs.mullvad}/bin/mullvad-daemon > /var/log/mullvad/daemon.log 2>&1 &
                DAEMON_PID=$!

                # Wait for daemon to be ready (max 30 attempts ≈ 6s)
                for i in $(seq 1 30); do
                  if ${pkgs.mullvad}/bin/mullvad status >/dev/null 2>&1; then
                    break
                  fi
                  sleep 0.2
                done

                # Log in automatically if the host passes an account token
                if [ -n "$MULLVAD_ACCOUNT" ]; then
                  ${pkgs.mullvad}/bin/mullvad account login "$MULLVAD_ACCOUNT"
                fi

                echo "Connecting to Mullvad routing network..."
                ${pkgs.mullvad}/bin/mullvad connect

                # Block on the daemon so tini can forward signals properly
                wait $DAEMON_PID
              '')
            ];
          };
        };
        EnvironmentFile = "%h/.config/mullvad/mullvad.env";
        AddCapability = "CAP_NET_ADMIN CAP_NET_RAW";
        AddDevice = "/dev/net/tun";
      };
      Service = {
        Restart = "always";
      };
      Install = {
        WantedBy = "default.target";
      };
    };
    alpine = {
      shareNetworkWith = "mullvad";
      Unit = {
        Description = "Alpine test container";
      };
      Container = {
        Image = "docker.io/library/alpine:latest";
        Exec = "sleep infinity";
      };
      Install = {
        WantedBy = "default.target";
      };
    };
  };
}
