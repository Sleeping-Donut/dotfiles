rec {
  publicDomain =
    "media"
    + "centre"
    + "hub"
    + "."
    + "com";
  localDomain = "fglab";
  tailnet = "time-augmented.ts.net";
  vcu = "vcu.${localDomain}";
  zwei = "zwei.${localDomain}";
  zweiTail = "zwei.${tailnet}";
  localACLs = ''
    allow 192.168.10.0/24; # lan
    allow 100.64.0.0/10; # tailnet
    allow fd7a:115c:a1e0::/48; # tailnet v6
    allow 127.0.0.1; # loopback
    deny all;
  '';
  toUrl = domain: port: "http://${domain}:${toString port}";
}
