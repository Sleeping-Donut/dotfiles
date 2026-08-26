{ config, lib, ... }:
let
  inherit (import ../net-helpers.nix) publicDomain localDomain localACLs toUrl;
in
{
  nd0.services.trek = {
    enable = true;
    dataDir = "/opt/trek/data";
    port = 3001;
  };

  services.nginx.virtualHosts."trek.zwei.${localDomain}" = let
    trekPort = config.nd0.services.trek.port;
  in {
    extraConfig = localACLs;
    locations."/" = {
      proxyPass = toUrl "zwei.${localDomain}" trekPort;
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."trek.${publicDomain}" = let
    trekPort = config.nd0.services.trek.port;
  in {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = toUrl "zwei.${localDomain}" trekPort;
      proxyWebsockets = true;
    };
  };
}
