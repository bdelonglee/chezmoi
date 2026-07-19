#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Nvim Opener
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "File path", "placeholder": "Placeholder" }
# @raycast.packageName Nvim Opener

# echo "Hello World! Argument1 value: "$1""

# Open the selected file in Neovim using WezTerm
wezterm start -- nvim "$1"
