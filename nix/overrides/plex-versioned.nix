{ pkgs }:
(args@{version, hash}:
	pkgs.plex.override {
		plexRaw = pkgs.plexRaw.overrideAttrs(old: rec {
			inherit version;
			src = pkgs.fetchurl {
				name = "plex-${version}";
				url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
				hash = hash;
			};
		});
	}
)

