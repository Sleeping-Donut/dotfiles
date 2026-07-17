{ config, lib, pkgs, pkgs-unstable, ... }:
let
  inherit (import ../net-helpers.nix) publicDomain localDomain localACLs toUrl;
in
{
  users.users.kavita.extraGroups = [ "labmembers" ];

  services.kavita = {
    enable = true;
    package = pkgs-unstable.kavita;
    dataDir = "/opt/kavita/data";
    tokenKeyFile = "/opt/kavita/kavita-token-key";
    settings.Port = 8082;
  };

  systemd.services.kavita = {
    unitConfig.RequiresMountsFor = [ "/mnt/amadeus/fg8" ];
    serviceConfig = {
      PrivateTmp = true;
      RemoveIPC = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = [""];
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectKernelLogs = true;
      LockPersonality = true;
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      RestrictRealtime = true;
    };
  };

  systemd.services.kavita.preStart = lib.mkForce (let
    settingsFormat = pkgs.formats.json { };
    appsettings = settingsFormat.generate "appsettings.json"
      ({ TokenKey = "@TOKEN@"; } // config.services.kavita.settings);
    dataDir = config.services.kavita.dataDir;
    existing = "${dataDir}/config/appsettings.json";
  in ''
    if [ -f '${existing}' ]; then
      ${lib.getExe pkgs.jq} -s '.[0] * .[1]' \
        '${existing}' ${appsettings} \
        > '${existing}.tmp' && mv '${existing}.tmp' '${existing}'
    else
      install -m600 ${appsettings} '${existing}'
    fi
    ${lib.getExe pkgs.replace-secret} '@TOKEN@' \
      ''${CREDENTIALS_DIRECTORY}/token '${existing}'
  '');

  services.nginx.virtualHosts."kavita.zwei.${localDomain}" = let
    kavitaPort = config.services.kavita.settings.Port;
  in {
    extraConfig = localACLs;
    locations."/" = {
      proxyPass = toUrl "zwei.${localDomain}" kavitaPort;
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."kavita.${publicDomain}" = let
    kavitaPort = config.services.kavita.settings.Port;
  in {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = toUrl "zwei.${localDomain}" kavitaPort;
      proxyWebsockets = true;
    };
    locations."/opds" = {
      proxyPass = toUrl "zwei.${localDomain}" kavitaPort;
      proxyWebsockets = true;
    };
  };

  nd0.rclone-backups.kavita = {
    enable = false;
    sourceDir = "/opt/kavita";
    destDir = "/mnt/amadeus/fg8/Backup/kavita";
    group = "labmembers";
    requiresMountsFor = [ "/mnt/amadeus/fg8" ];
    pruneRemote = true;
    OnCalendar = [ "Sun *-*-* 03:30:00" ]; # Weekly at 03:30 Sun
    whitelist = [
      "/kavita-token-key"
      "/data/config/kavita.db"
      "/data/config/appsettings.json"
      "/data/config/covers/**"
      "/data/config/bookmarks/**"
      "/data/config/themes/**"
      "/data/config/favicons/**"
    ];
  };
}
