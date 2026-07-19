#!/bin/sh
set -e

target="$HOME/.config/aerospace"
if [ ! -d "$target/.git" ]; then
  git clone git@github.com:bdelonglee/aerospace.git "$target"
fi
