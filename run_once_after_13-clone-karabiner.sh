#!/bin/sh
set -e

target="$HOME/Documents/PROJECTS/DEV/karabiner"
if [ ! -d "$target/.git" ]; then
  mkdir -p "$(dirname "$target")"
  git clone git@github.com:bdelonglee/karabiner.git "$target"
fi

mkdir -p "$HOME/.config/karabiner"
link="$HOME/.config/karabiner/karabiner.json"
if [ ! -L "$link" ]; then
  if [ -f "$link" ]; then
    mv "$link" "$link.bak"
  fi
  ln -s "$target/karabiner.json" "$link"
fi
