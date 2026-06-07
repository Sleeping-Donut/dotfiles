#!/usr/bin/env sh

set -eu

curl -sSf 'https://plex.tv/api/downloads/5.json/?channel=plexpass' \
	| jq -r '.computer.Linux.releases[] | select(.build == "linux-x86_64" and .distro == "debian") | .url' \
	| sed 's:.*/plexmediaserver_\([^_]*\)_.*:\1:'
