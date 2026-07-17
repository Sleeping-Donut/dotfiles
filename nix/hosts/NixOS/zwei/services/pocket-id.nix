{ config, lib, pkgs, ... }:
let
  inherit (import ../net-helpers.nix) publicDomain toUrl zwei;
in
{
  users.users.pocket-id.extraGroups = [ "labmembers" ];
  systemd.tmpfiles.settings.pocket-id = {
    "/opt/pocket-id/data" = {
      d = {
        user = "pocket-id";
        group = "pocket-id";
        mode = "0700";
      };
    };
  };
  services.pocket-id = {
    enable = true;
    dataDir = "/opt/pocket-id/data";
    settings = {
      APP_URL = "https://id.${publicDomain}";
      TRUST_PROXY = true;
      HOST = "127.0.0.1";
      PORT = 1411;
    };
    credentials = {
      ENCRYPTION_KEY = "/opt/pocket-id/encryption-key";
    };
  };
  services.nginx.virtualHosts."id.${publicDomain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = toUrl zwei 1411;
      proxyWebsockets = true;
    };
  };
}
