#!/usr/bin/env sh

curl -s 'https://plex.tv/api/downloads/5.json/?channel=plexpass' \
	| jq '[ .computer.Linux.releases.[] | select(.build == "linux-x86_64" and .distro == "debian") | .url ]' \
	| grep '"' \
	| sed 's:.*/plexmediaserver_\([^_]*\)_.*:\1:'
