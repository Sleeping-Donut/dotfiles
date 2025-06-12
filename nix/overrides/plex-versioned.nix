{ pkgs }:
( args@{ version, hash }: let

	arch = if pkgs.stdenv.hostPlatform.system == "aarch64-linux" then "arm64"
		else if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then "amd64"
		else "armhf"; # Should never reach here because support so low

	url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_${arch}.deb";

	plexVersionedRaw = pkgs.plexRaw.overrideAttrs (old: {
		inherit version;
		name = "${old.pname}-${version}";
		src = pkgs.fetchurl { inherit url hash;};
	});
in
	pkgs.plex.override { plexRaw = plexVersionedRaw; }
)

