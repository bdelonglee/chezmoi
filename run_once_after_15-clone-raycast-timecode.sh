#!/bin/sh
set -e

target="$HOME/Documents/PROJECTS/DEV/raycast_timecode"
if [ ! -d "$target/.git" ]; then
  mkdir -p "$(dirname "$target")"
  git clone git@github.com:bdelonglee/raycast_Timecode.git "$target"
fi
