{ config, lib, pkgs, pkgs-unstable, ... }:
let
  inherit (import ../net-helpers.nix) publicDomain localDomain localACLs tailnet toUrl;
in
{
  users.users.immich.extraGroups = [ "labmembers" ];
  systemd.tmpfiles.settings.immich-state = {
    "/opt/immich" = {
      d = {
        user = "immich";
        group = "immich";
        mode = "0700";
      };
    };
  };
  systemd.tmpfiles.settings.immich-media = lib.mkForce {}; # mediaLocation on NFS, no tmpfiles meddling
  systemd.services.immich-server = {
    unitConfig.RequiresMountsFor = [ "/mnt/amadeus/fg8" ];
    serviceConfig = {
      PrivateMounts = lib.mkForce false;   # needed for NFS automount propagation
      PrivateUsers = lib.mkForce false;    # needed for NFS UID mapping
    };
  };
  services.immich = {
    enable = true;
    package = pkgs-unstable.immich;
    host = "127.0.0.1";
    mediaLocation = "/mnt/amadeus/fg8/Media/Photos";
    # port = 2283; # default
    openFirewall = true;
    machine-learning.enable = false; # no hw ;(
  };
  nd0.rclone-backups.immich = {
    enable = false;
    sourceDir = "/opt/immich";
    destDir = "/mnt/amadeus/fg8/Backup/immich";
    group = "labmembers";
    requiresMountsFor = [ "/mnt/amadeus/fg8" ];
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:50:00" ]; # weekly at 03:50 Sun
  };
  services.nginx.virtualHosts."immich.zwei.${localDomain}" = {
    serverAliases = [ "immich.zwei.${tailnet}" ];
    extraConfig = localACLs + ''
      client_max_body_size 50000M;
      proxy_request_buffering off;
      client_body_buffer_size 1024k;
      proxy_read_timeout 600s;
      proxy_send_timeout 600s;
      send_timeout 600s;
    '';
    locations."/" = {
      proxyPass = toUrl "zwei.${localDomain}" config.services.immich.port;
      proxyWebsockets = true;
    };
  };
  services.nginx.virtualHosts."immich.${publicDomain}" = {
    enableACME = true;
    forceSSL = true;
    extraConfig = ''
      client_max_body_size 50000M;
      proxy_request_buffering off;
      client_body_buffer_size 1024k;
      proxy_read_timeout 600s;
      proxy_send_timeout 600s;
      send_timeout 600s;
    '';
    locations."/" = {
      proxyPass = toUrl "zwei.${localDomain}" config.services.immich.port;
      proxyWebsockets = true;
    };
  };
}
