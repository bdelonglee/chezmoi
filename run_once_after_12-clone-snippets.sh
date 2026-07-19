#!/bin/sh
set -e

target="$HOME/.config/snippets"
if [ ! -d "$target/.git" ]; then
  git clone git@github.com:bdelonglee/snip.git "$target"
fi
