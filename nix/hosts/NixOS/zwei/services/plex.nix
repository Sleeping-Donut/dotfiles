{ config, lib, pkgs, sources, ... }:
let
  inherit (import ../net-helpers.nix) localDomain localACLs toUrl zwei;
  plex-versioned = import sources.overrides.plex-versioned { inherit pkgs; };
in
{
  users.users.plex = {
    uid = 193;
    isSystemUser = true;
    description = "Plex media server service account";
    group = "labmembers";
  };
  services.plex = {
    enable = true;
    group = "labmembers";
    dataDir = "/opt/plex/data";
    extraScanners = [ ];
    extraPlugins = [ ];
    openFirewall = true;
    package = plex-versioned {
      version = "1.43.2.10687-563d026ea";
      # To get hash for new version use `sh nix/scripts/getPkgHash.sh 'plex' '<VERSION>'
      hash = "sha256-dgkj0Uny/d0DnExgYWjxfl2cFsiattlGzb7Guzmtro4=";
    };
  };
  nd0.rclone-backups.plex = {
    enable = false;
    sourceDir = "/opt/plex/data/Plex Media Server";
    destDir = "/mnt/amadeus/fg8/Backup/plex/Plex Media Server";
    group = "labmembers";
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:00:00" ]; # weekly at 0300 Sun
    whitelist = [
      "/Preferences.xml"
      "/Metadata/**"
      "/.LocalAdminToken"
      "/Plug-in Support/**"
      "/Plug-ins/**"
      "/Codecs/**"
      "/Scanners/**"
      "/Cache/**"
      "/Logs/**"
      "/Crash Reports/**"
      "/Diagnostics/**"
    ];
  };
  services.nginx.virtualHosts."zwei.${localDomain}".locations."/plex" = {
    proxyPass = toUrl zwei 32400;
    proxyWebsockets = true;
    extraConfig = ''
      proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
      proxy_set_header X-Plex-Device $http_x_plex_device;
      proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
      proxy_set_header X-Plex-Platform $http_x_plex_platform;
      proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
      proxy_set_header X-Plex-Provides $http_x_plex_provides;
      proxy_set_header X-Plex-Product $http_x_plex_product;
      proxy_set_header X-Plex-Version $http_x_plex_version;
      proxy_set_header X-Plex-Device-Screen-Resolution $http_x_plex_device_screen_resolution;
      proxy_set_header X-Plex-Token $http_x_plex_token;
    '';
  };
}
