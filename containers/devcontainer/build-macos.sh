#!/bin/sh
container build --tag nixos-base "$(cd "$(dirname "$0")" && pwd)"
