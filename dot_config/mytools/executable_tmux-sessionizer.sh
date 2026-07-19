#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
    # no server running yet (e.g. right after reboot) -- nothing to list from
    # tmux itself, so fall back to what tmux-continuum would restore
    if [[ -z $sessions ]]; then
        resurrect_last="$HOME/.config/tmux/resurrect/last"
        if [[ -e $resurrect_last ]]; then
            sessions=$(awk -F'\t' '{print $2}' "$resurrect_last" | sort -u)
        fi
    fi
    dirs=$(find -L ~/Documents/PROJECTS/DEV /Users/bdelonglee/Documents/PROJECTS/HQR -mindepth 1 -maxdepth 1 -type d)
    selected=$(printf "%s\n%s\n%s\n" "$sessions" "$dirs" "$HOME/Documents/PERSO/Notes" | sed '/^$/d' | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# OK - tmux is not running
# (starting the server here sources tmux.conf, which kicks off tmux-continuum's
# background session restore -- it may race us and create $selected_name first,
# so create-or-noop then attach instead of assuming new-session will succeed)
if [[ -z $tmux_running ]]; then
    tmux new-session -ds $selected_name -c "$selected" 2>/dev/null
    tmux attach -t $selected_name
    exit 0
fi

# OK - tmux is running but client is not attached, session with selected_name does not exist
if [[ -z $TMUX ]] && ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -s $selected_name -c "$selected"
    tmux a -t $selected_name
    exit 0
fi

# OK - tmux is running but client is not attached, session with selected_name exists
if [[ -z $TMUX ]] && tmux has-session -t=$selected_name 2> /dev/null; then
    tmux a -t $selected_name
    exit 0
fi

# OK - tmux is running and client is attached, session with selected_name does not exist
if [[ ! -z $TMUX ]] && ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c "$selected"
    tmux switch-client -t $selected_name
    exit 0
fi

# OK - tmux is running and client is attached, session with selected_name exists
if [[ ! -z $TMUX ]] && tmux has-session -t=$selected_name 2> /dev/null; then
    tmux switch-client -t $selected_name
    exit 0
fi

