#!/bin/sh

# Set up nix directories if they don't exist
mkdir -p /nix/store /nix/var/nix/db /nix/var/nix/profiles

# Initialize nix database if empty
if [ ! -f /nix/var/nix/db/.db.sqlite ]; then
  nix-store --init
fi

# Start nix-daemon in background
nix-daemon &
DAEMON_PID=$!

# Wait for daemon to be ready
sleep 1

# Drop to shell
exec "$@"
