{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  inherit (import ../net-helpers.nix) publicDomain toUrl zwei headnet headnetV4 headnetV6;

  headscaleHost = "hs.${publicDomain}";

  # Nodes auto-register as <hostname>.<headnet>; must differ from the
  # server_url domain. Shared with the service nginx vhosts via net-helpers.

  headscalePort = 8080;

  # zwei's address inside the headnet. With sequential allocation the first
  # node registered gets 100.64.0.1; confirm with `headscale nodes list`.
  zweiHeadIP = "100.64.0.1";

  # Services hosted on zwei that also get a MagicDNS name.
  serviceAliases = [
    "id" # pocket-id
    "trek"
  ];
in
{
  # Secret for the Pocket-ID OIDC client. Create it out of band as root:
  #   install -d -m 0700 -o headscale -g headscale /opt/headscale
  #   printf '%s' '<client-secret>' > /opt/headscale/oidc-client-secret
  #   chown headscale:headscale /opt/headscale/oidc-client-secret
  #   chmod 0400 /opt/headscale/oidc-client-secret
  systemd.tmpfiles.settings."10-headscale" = {
    "/opt/headscale".d = {
      user = "headscale";
      group = "headscale";
      mode = "0700";
    };
  };

  services.headscale = {
    enable = true;
    package = pkgs-unstable.headscale;
    address = "127.0.0.1"; # nginx terminates TLS and proxies to here
    port = headscalePort;

    settings = {
      server_url = "https://${headscaleHost}";
      trusted_proxies = [ "127.0.0.1/32" "::1/128" ];

      # Node IP ranges, shared with the nginx ACLs via net-helpers.
      prefixes = {
        v4 = headnetV4;
        v6 = headnetV6;
      };

      oidc = {
        issuer = "https://id.${publicDomain}";
        client_id = "headscale";
        client_secret_path = "/opt/headscale/oidc-client-secret";
        scope = [ "openid" "profile" "email" "groups" ];
        allowed_groups = [ "headscale_users" ];
        pkce = {
          enabled = true;
          method = "S256";
        };
      };

      dns = {
        magic_dns = true;
        base_domain = headnet;
        # Keep each client's own resolvers, MagicDNS only answers the base domain
        override_local_dns = false;

        extra_records = map (name: {
          name = "${name}.${headnet}";
          type = "A";
          value = zweiHeadIP;
        }) serviceAliases;
      };

      # Self-hosted DERP relay. Tailscale's public DERP map stays as a
      # fallback; add `urls = [];` to use only this server.
      derp = {
        server = {
          enabled = true;
          # These must be set explicitly; otherwise headscale registers the
          # embedded region as id 0 with an empty code, which clients can't
          # relay through (breaks remote peers that can't connect directly).
          region_id = 999;
          region_code = "headscale";
          region_name = "Headscale Embedded DERP";
          stun_listen_addr = "0.0.0.0:3478";
          verify_clients = true;
          # No ipv4/ipv6: the WAN IP is dynamic, so clients resolve the
          # server_url hostname (the public domain) instead.
        };
        # urls = [];
      };

      policy = {
        mode = "file";
        path = pkgs.writeText "headscale-policy.hujson" ''
          {
            "hosts": {
              "zwei": "${zweiHeadIP}"
            },
            "groups": {
              "group:admins": ["nathan0d@"],
              "group:fgmember": ["rianna@"]
            },
            "grants": [
              { "src": ["group:admins"], "dst": ["*"], "ip": ["*"] },
              { "src": ["autogroup:member"], "dst": ["autogroup:self"], "ip": ["*"] },
              { "src": ["group:fgmember"], "dst": ["zwei"], "ip": ["tcp:80"] }
            ]
          }
        '';
      };
    };
  };

  # STUN for the embedded DERP server (raw UDP, bypasses nginx).
  networking.firewall.allowedUDPPorts = [ 3478 ];

  # TLS + reverse proxy for the Tailscale control protocol and /derp endpoint
  services.nginx.virtualHosts."${headscaleHost}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = toUrl zwei headscalePort;
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
      '';
    };
  };
}
