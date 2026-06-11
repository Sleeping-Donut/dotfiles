#!/bin/sh

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${1:-4096}"

container run --rm -d --init \
  --dns 1.1.1.1 \
  --mount type=bind,source="${DOTFILES_DIR}",target=/root/dotfiles \
  --mount type=tmpfs,target=/root/dotfiles/.containerignore \
  --mount type=bind,source="${DOTFILES_DIR}/.git",target=/root/dotfiles/.git,readonly \
  --mount type=bind,source="${DOTFILES_DIR}/.containerignore/opencode/config",target=/.config/opencode \
  --mount type=bind,source="${DOTFILES_DIR}/.containerignore/opencode/data",target=/.local/share/opencode \
  --workdir /root/dotfiles \
  --publish "${PORT}:4096" \
  --name dotfiles-serve \
  nixos-base \
  bash -c 'exec opencode serve --hostname 0.0.0.0 --port 4096 --mdns --print-logs'
