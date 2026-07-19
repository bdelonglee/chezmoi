#!/usr/bin/env bash
#   [hotkey]
#
#     global:
#       Esc:quit
#       Enter:select/open
#       Home:first
#       End:last
#       C-k:preview-page-up
#       C-j:preview-page-down
#
#     edit:
#       Tab:select multiple files (tmux only)
#       C-v:rename (imv)
#       C-r:reload
#       Shift-delete:trash (gio trash)
#       C-n/p:navigate down/up
#
#     snippet:
#       C-o:edit-line
#       C-f:edit-file
#       C-r:reload
#       C-n/p|tab/shift-tab:navigate down/up
#
#     info:
#       q:quit


export FZF_DEFAULT_OPTS="-e -i --info=hidden --layout=reverse --scroll-off=5 --tiebreak=index --bind 'home:first,end:last,ctrl-k:preview-page-up,ctrl-j:preview-page-down,ctrl-y:preview-up,ctrl-e:preview-down,ctrl-/:change-preview-window(hidden|)'"

mycheatdir="$HOME/.config/snippets"


mytui() {
      selected=$(grep -nrH '^####\ ' "$mycheatdir"/* | fzf -d ' ' --with-nth 2.. \
        --prompt="Snippet >>> copy to clipboard: " \
        --bind 'ctrl-f:execute:${EDITOR:-nano} $(echo {} | cut -d: -f1) >/dev/tty' \
        --bind 'ctrl-o:execute:${EDITOR:-nano} +$(echo {} | cut -d: -f2) $(echo {} | cut -d: -f1) >/dev/tty' \
        --bind "ctrl-r:reload:grep -nrH '^####; ' "$mycheatdir"/* " \
        --bind 'home:first,end:last,tab:down,shift-tab:up' \
        --header 'C-o:edit-line C-r:reload C-n/p:down/up C-j/k:preview-pagedown/up' \
        --preview-window 'down' \
        --preview 'awk '/'"$(echo {} | cut -d " " -f2-)"\\n'/' RS="\n\n\n" "$(echo {} | cut -d: -f1)" | \
                   bat --color=always -pp -l "$(echo {} | cut -d: -f1 | rev | cut -d. -f1 | rev)"'
      )
      [ -z "$selected" ] && exit
      file_name="$(echo "$selected" | cut -d: -f1)"
      snippet_title="$(echo "$selected" | cut -d " " -f2-)"
      selected=$(awk '/'"$snippet_title"'/' RS="\n\n\n" "$file_name" | sed -e '/^####\ /d' -e '/^###\ /d' -e '/^##\ /d' )
      ## copy to clipboard
      ## X11=xsel/xclip; wayland=wl-copy; winos(vista+)=clip; cygwin=/dev/clipboard; macos=pbcopy; android=termux
      # printf %s "$selected" | xsel -b 2>/dev/null || printf %s "$selected" | xclip -selection clipboard -r 2>/dev/null
      # printf %s "$selected" | wl-copy 2>/dev/null
      # printf %s "$selected" | clip 2>/dev/null
      # (printf %s "$selected" > /dev/clipboard) 2>/dev/null
      printf %s "$selected" | pbcopy 2>/dev/null
      # printf %s "$selected" | termux-clipboard-set 2>/dev/null
      (printf %s "$selected" | tmux load-buffer -) 2>/dev/null
}



if [ -z "$1" ]; then
  mytui
fi
