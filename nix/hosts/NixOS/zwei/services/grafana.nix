{ config, lib, pkgs, pkgs-unstable, ... }:
let
  inherit (import ../net-helpers.nix) localDomain toUrl zwei;
in
{
  users.users.grafana = {
    # just to keep uid between installs
    uid = 196;
    isSystemUser = true;
  };
  services.grafana = {
    enable = true;
    package = pkgs-unstable.grafana;
    dataDir = "/opt/grafana";
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        enforce_domain = false;
        serve_from_sub_path = true;
        # domain = "zwei.fglab";
        root_url = "http://zwei.fglab/grafana/";
      };
      security.secret_key = "SW2YcwTIb9zpOOhoPsMm"; # Shhh its very secret
    };
    provision.datasources.settings.datasources = [
      {
        name = "prometheus";
        type = "prometheus";
        access = "proxy";
        isDefault = true;
        url = "localhost:${toString config.services.prometheus.port}";
      }
    ];
  };
  nd0.rclone-backups.grafana = {
    enable = false;
    sourceDir = config.services.grafana.dataDir;
    destDir = "/mnt/amadeus/fg8/Backup/grafana";
    group = "labmembers";
    requiresMountsFor = [ "/mnt/amadeus/fg8" ];
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 04:30:00" ]; # weekly at 0330 Sun
    blacklist = [
      "/conf"
      "/tools"
    ]; # they're symlinks into nix store
  };
  services.nginx.virtualHosts."zwei.${localDomain}".locations = let
    grafanaUrl = toUrl zwei config.services.grafana.settings.server.http_port;
  in {
    "/grafana" = {
      proxyPass = "${grafanaUrl}";
      proxyWebsockets = true;
    };
    "/grafana/api/live" = {
      proxyPass = "${grafanaUrl}";
      proxyWebsockets = true;
    };
  };
}
