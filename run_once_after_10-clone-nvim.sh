#!/bin/sh
set -e

target="$HOME/.config/nvim"
if [ ! -d "$target/.git" ]; then
  git clone git@github.com:bdelonglee/nvim.git "$target"
fi
