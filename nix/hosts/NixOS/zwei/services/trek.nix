{ config, lib, ... }:
let
  inherit (import ../net-helpers.nix) publicDomain localDomain localACLs toUrl;
  trekDataDir = "/opt/trek/data";
  trekUploadsDir = "/opt/trek/uploads";
in
{
  virtualisation.oci-containers.containers.trek = {
    image = "mauriceboe/trek:3.4.1";
    ports = [ "127.0.0.1:3001:3000" ];
    volumes = [
      "${trekDataDir}:/app/data"
      "${trekUploadsDir}:/app/uploads"
    ];
    environment = {
      NODE_ENV = "production";
      PORT = "3000";
    };
    extraOptions = [
      "--health-cmd wget -qO- http://localhost:3000/api/health || exit 1"
      "--health-interval 30s"
      "--health-timeout 5s"
      "--health-start-period 15s"
      "--health-retries 3"
    ];
  };

  systemd.tmpfiles.settings."10-trek".${trekDataDir}.d = {
    user = "root";
    group = "root";
    mode = "0755";
  };
  systemd.tmpfiles.settings."10-trek".${trekUploadsDir}.d = {
    user = "root";
    group = "root";
    mode = "0755";
  };

  services.nginx.virtualHosts."trek.zwei.${localDomain}" = {
    extraConfig = localACLs;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."trek.${publicDomain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3001";
      proxyWebsockets = true;
    };
  };
}
