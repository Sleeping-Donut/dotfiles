rec {
  publicDomain =
    "media"
    + "centre"
    + "hub"
    + "."
    + "com";
  localDomain = "fglab";
  headnet = "time-augmented.hs.internal";
  headnetV4 = "100.64.0.0/10";
  headnetV6 = "fd7a:115c:a1e0::/48";
  vcu = "vcu.${localDomain}";
  zwei = "zwei.${localDomain}";
  zweiHead = "zwei.${headnet}";
  localACLs = ''
    # TODO: make local only, excl headnet once figured out how to do perms better
    allow 192.168.10.0/24; # lan
    allow ${headnetV4}; # headnet
    allow ${headnetV6}; # headnet v6
    allow 127.0.0.1; # loopback
    deny all;
  '';
  headnetACLs = ''
    allow ${headnetV4}; # headnet v4
    allow ${headnetV6}; # headnet v6
    allow 127.0.0.1; # loopback
    deny all;
  '';
  toUrl = domain: port: "http://${domain}:${toString port}";
}
