{ config, lib, pkgs, pkgs-unstable, ... }:
let
  inherit (import ../net-helpers.nix) localDomain toUrl zwei;
in
{
  users.users.jellyfin = {
    uid = 995;
    isSystemUser = true;
    description = "Jellyfin Server service account";
    group = "labmembers";
  };
  services.jellyfin =
    let
      jellyDir = "/opt/jellyfin";
    in
    {
      enable = true;
      group = "labmembers";
      dataDir = "${jellyDir}/data";
      logDir = "${jellyDir}/logs";
      configDir = "${jellyDir}/config";
      cacheDir = "${jellyDir}/cache";
      openFirewall = true;
      package = pkgs-unstable.jellyfin;
    };
  nd0.rclone-backups.jellyfin = {
    enable = false;
    sourceDir = "/opt/jellyfin";
    destDir = "/mnt/amadeus/fg8/Backup/jellyfin";
    group = "labmembers";
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:15:00" ]; # weekly at 0300 Sun
  };
  services.nginx.virtualHosts."zwei.${localDomain}".locations."/jellyfin" = {
    proxyPass = toUrl zwei 8096;
    proxyWebsockets = true;
  };
}
