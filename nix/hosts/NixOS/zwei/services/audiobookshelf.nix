{ config, lib, pkgs, pkgs-unstable, ... }:
let
  inherit (import ../net-helpers.nix) publicDomain localDomain toUrl zwei;
in
{
  users.users.audiobookshelf = {
    extraGroups = [ "labmembers" ];
    home = lib.mkForce "/opt/audiobookshelf/data"; # the module has a path for this so just in case, override
  };
  systemd.tmpfiles.settings.audiobookshelf-data = {
    "/opt/audiobookshelf/data" = {
      d = {
        user = "audiobookshelf";
        group = "audiobookshelf";
        mode = "0750";
      };
    };
  };
  systemd.services.audiobookshelf.serviceConfig = {
    WorkingDirectory = lib.mkForce "/opt/audiobookshelf/data";
  };
  services.audiobookshelf = {
    enable = true;
    package = pkgs-unstable.audiobookshelf;
    dataDir = "/opt/audiobookshelf/data";
    port = 13378;
    openFirewall = true;
  };
  nd0.rclone-backups.audiobookshelf = {
    enable = false;
    sourceDir = config.services.audiobookshelf.dataDir;
    destDir = "/mnt/amadeus/fg8/Backup/audiobookshelf/data";
    group = "labmembers";
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:45:00" ]; # weekly at 03:45 Sun
    whitelist = [
      "/config/**"
      "/metadata/items/**"
      "/metadata/authors/**"
      "/metadata/backups/**"
    ];
  };
  services.nginx.virtualHosts."zwei.${localDomain}".locations."/audiobookshelf" = {
    proxyPass = toUrl zwei config.services.audiobookshelf.port;
    proxyWebsockets = true;
  };
  services.nginx.virtualHosts."audiobookshelf.${publicDomain}" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      client_max_body_size 10240M;
      proxy_read_timeout 600s;
      proxy_send_timeout 600s;
      send_timeout 600s;
    '';
    locations."/audiobookshelf" = {
      proxyPass = toUrl zwei config.services.audiobookshelf.port;
      proxyWebsockets = true;
    };
  };
}
