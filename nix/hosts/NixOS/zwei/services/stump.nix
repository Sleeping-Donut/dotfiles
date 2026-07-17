{ config, lib, ... }:
let
  inherit (import ../net-helpers.nix) publicDomain localDomain localACLs toUrl;
in
{
  nd0.services.stump = {
    enable = true;
    group = "labmembers";
    dataDir = "/opt/stump/data";
    environment = {
      STUMP_OIDC_ENABLED = "true";
      STUMP_OIDC_ISSUER_URL = "https://id.${publicDomain}";
      STUMP_OIDC_CLIENT_ID = "stump";
      STUMP_OIDC_ALLOW_REGISTRATION = "true";
      STUMP_OIDC_DISABLE_LOCAL_AUTH = "true";
    };
    secretFiles = {
      STUMP_OIDC_CLIENT_SECRET = "/opt/stump/oidc-client-secret";
    };
  };
  nd0.rclone-backups.stump = {
    enable = false;
    sourceDir = "/opt/stump";
    destDir = "/mnt/amadeus/fg8/Backup/stump";
    group = "labmembers";
    pruneRemote = true;
    whitelist = [
      "/data/config/**"
      "/data/stump.db"
    ];
  };
  services.nginx.virtualHosts."stump.zwei.${localDomain}" = let
    stumpPort = config.nd0.services.stump.port;
  in {
    extraConfig = localACLs;
    locations."/" = {
      proxyPass = toUrl "zwei.${localDomain}" stumpPort;
      proxyWebsockets = true;
    };
  };
  services.nginx.virtualHosts."stump.${publicDomain}" = let
    stumpPort = config.nd0.services.stump.port;
  in {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = toUrl "zwei.${localDomain}" stumpPort;
      proxyWebsockets = true;
    };
  };
}
