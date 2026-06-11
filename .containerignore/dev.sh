#!/bin/sh

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

container run --rm -it --init \
  --dns 1.1.1.1 \
  --mount type=bind,source="${DOTFILES_DIR}",target=/root/dotfiles \
  --mount type=tmpfs,target=/root/dotfiles/.containerignore \
  --mount type=bind,source="${DOTFILES_DIR}/.git",target=/root/dotfiles/.git,readonly \
  --mount type=bind,source="${DOTFILES_DIR}/.containerignore/opencode/config",target=/.config/opencode \
  --mount type=bind,source="${DOTFILES_DIR}/.containerignore/opencode/data",target=/.local/share/opencode \
  --workdir /root/dotfiles \
  --name dotfiles-dev \
  nixos-base \
  bash
