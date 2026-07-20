# dotfiles (chezmoi)

Managed with [chezmoi](https://chezmoi.io). This repo is the chezmoi source
directory (`~/.local/share/chezmoi`).

## Fresh machine bootstrap

```sh
brew install chezmoi   # or: sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply bdelonglee/chezmoi
```

This writes the managed files into place and runs the `run_once_after_*`
scripts, which `git clone` the independently-managed repos below into their
usual locations.

## What's here (directly managed)

- `.zshrc`
- `~/.config/tmux/tmux.conf` (just the config — `plugins/` and `resurrect/`
  are TPM-installed / runtime state, not tracked)
- `~/.wezterm.lua`
- `~/.config/starship.toml`
- `~/.config/mytools/`
- `~/.config/cheatsheet/` (shortcut reference pages for `right⌘+/` in
  Karabiner — see the karabiner repo's README)

## What's cloned, not managed (independent repos)

These already have their own git history and remotes. chezmoi only triggers
the initial `git clone` on a new machine via `run_once_after_*` scripts —
after that, they're edited and pushed normally from their live location,
same as before. They are deliberately **not** `.chezmoiexternal` entries,
since externals are read-only vendored content that `chezmoi apply` would
overwrite from the pinned source, which would fight with editing them
directly.

| Repo | Cloned to |
|------|-----------|
| `bdelonglee/nvim` | `~/.config/nvim` |
| `bdelonglee/aerospace` | `~/.config/aerospace` |
| `bdelonglee/snip` | `~/.config/snippets` |
| `bdelonglee/karabiner` | `~/Documents/PROJECTS/DEV/karabiner`, symlinked to `~/.config/karabiner/karabiner.json` |
| `bdelonglee/raycastNV` | `~/Documents/PROJECTS/DEV/raycast` (Raycast extension dev project) |
| `bdelonglee/raycast_Timecode` | `~/Documents/PROJECTS/DEV/raycast_timecode` (Raycast extension dev project) |

Not included: `~/.config/raycast` (extensions cache / AI data, mostly downloaded
content, not hand-authored config).

## Everyday use

- Edit a live file, then pull the change back into this repo:
  `chezmoi re-add ~/.zshrc`
- Edit the source copy directly, then push it out:
  `chezmoi edit ~/.config/starship.toml && chezmoi apply`
- Preview what `apply` would change: `chezmoi diff`
