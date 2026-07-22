#!/bin/sh
set -e

target="$HOME/.config/tmux/plugins/tmux-catppuccin"
if [ ! -d "$target/.git" ]; then
  git clone git@github.com:bdelonglee/tmux-catppuccin.git "$target"
fi
