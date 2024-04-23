#!/usr/bin/env sh

# Package Handlers
get_plex_hash() {
	ver="$1"
	nix-prefetch-url "https://downloads.plex.tv/plex-media-server-new/${ver}/debian/plexmediaserver_${ver}_amd64.deb" | xargs nix hash convert --hash-algo sha256
}

# Start
if [[ "$#" -ne "2" ]]; then
	echo "Incorrect number of arguments: $# \nUseage: \ngetPkgHash <package_name> <version>"
	exit 1
fi
pkg="$1"
ver="$2"

if [[ "$pkg" = "plex" ]]; then
	get_plex_hash "$ver"
else
	echo "No handler exists for the package '${pkg}'"
	exit 1
fi
