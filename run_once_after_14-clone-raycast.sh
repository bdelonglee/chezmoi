#!/bin/sh
set -e

target="$HOME/Documents/PROJECTS/DEV/raycast"
if [ ! -d "$target/.git" ]; then
  mkdir -p "$(dirname "$target")"
  git clone git@github.com:bdelonglee/raycastNV.git "$target"
fi
