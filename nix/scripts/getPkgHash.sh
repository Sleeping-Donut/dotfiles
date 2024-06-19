#!/usr/bin/env sh

# fn(url, hash)
get_pkg_hash() {
	url="$1"
	hash="$2"
	nix-prefetch-url "$url" | xargs nix hash convert --hash-algo "$hash" --from nix32
}

# Package Handlers

# fn(ver, hash_algo)
get_plex_hash() {
	ver="$1"
	hash_algo="$2"
	if [[ "$ver" = '' ]]; then
		ver=$(sh $(dirname "$0")/getLatestPlexVer.sh)
		if [ $? -ne 0 ]; then
			echo 'No plex ver provided and failed to fetch latest ver' \
			exit 1
		fi
	fi
	url="https://downloads.plex.tv/plex-media-server-new/${ver}/debian/plexmediaserver_${ver}_amd64.deb"
	echo "$ver"
	get_pkg_hash "$url" "$hash_algo"
}

incorrect_args() {
	printf "Incorrect number of arguments: $# \nUseage: \ngetPkgHash <package_name> [<version>] [<HASH ALGORITHM>]\n"
	exit 1
}

# Start
# Set package version and hash algorithm
pkg="$1"
ver="$2"
hash_algo='sha256'

# Until correct way to generate hash using nix-prefetch-url and nix hash convert, omit
#if [[ "$#" -eq "3" ]]; then
#	hash_algo="$3"
#fi

if [[ "$pkg" = "plex" ]]; then
	if [[ "$#" -ne "1" && "$#" -ne "2" && "$#" -ne "3" ]]; then incorrect_args; fi
	get_plex_hash "$ver" "$hash_algo"
else
	echo "No handler exists for the package '${pkg}'"
	exit 1
fi
