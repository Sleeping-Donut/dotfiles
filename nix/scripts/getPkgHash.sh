#!/usr/bin/env sh

# fn(url, hash)
get_pkg_hash() {
	url="$1"
	hash="$2"
	nix-prefetch-url "$url" | xargs nix hash convert --hash-algo "$hash"
}

# Package Handlers

# fn(ver, hash_algo)
get_plex_hash() {
	ver="$1"
	hash_algo="$2"
	url="https://downloads.plex.tv/plex-media-server-new/${ver}/debian/plexmediaserver_${ver}_amd64.deb"
	get_pkg_hash "$url" "$hash_algo"
}

# Start
if [[ "$#" -ne "2" && "$#" -ne "3" ]]; then
	printf "Incorrect number of arguments: $# \nUseage: \ngetPkgHash <package_name> <version> [<HASH ALGORITHM>]\n"
	exit 1
fi

# Set package version and hash algorithm
pkg="$1"
ver="$2"
hash_algo="sha256"

# Until correct way to generate hash using nix-prefetch-url and nix hash convert, omit
#if [[ "$#" -eq "3" ]]; then
#	hash_algo="$3"
#fi

if [[ "$pkg" = "plex" ]]; then
	get_plex_hash "$ver" "$hash_algo"
else
	echo "No handler exists for the package '${pkg}'"
	exit 1
fi
