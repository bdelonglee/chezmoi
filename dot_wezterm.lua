-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- config.font = wezterm.font("Monaspace Argon NF")
config.font = wezterm.font("JetBrains Mono")
-- config.font = wezterm.font("mononoki")
-- config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 19

config.enable_tab_bar = false

-- Needed so terminal apps (tmux) can distinguish Ctrl+Alt+Shift+<key>
-- from Ctrl+Alt+<key> -- legacy encoding collapses Ctrl+letter to a
-- control byte and loses the Shift bit.
config.enable_kitty_keyboard = true

config.window_decorations = "RESIZE"
-- config.window_background_opacity = 0.8
-- config.macos_window_background_blur = 10

-- config.color_scheme = "Catppuccin Mocha" -- or Macchiato, Frappe, Latte
-- config.color_scheme = "Catppuccin Mocha" -- or Macchiato, Frappe, Latte
config.color_scheme = "Tokyo Night (Gogh)" -- or Macchiato, Frappe, Latte

-- Disable specific key bindings
config.keys = { -- Disable Ctrl+Shift+L (default: show debug overlay)
	{
		key = "L",
		mods = "CTRL|SHIFT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
	-- Disable Ctrl+Shift+H (default: hide window)
	{
		key = "H",
		mods = "CTRL|SHIFT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{ key = "j", mods = "CTRL|SHIFT", action = wezterm.action.SendKey({ key = "DownArrow" }) },
	{ key = "k", mods = "CTRL|SHIFT", action = wezterm.action.SendKey({ key = "UpArrow" }) },
	{ key = "0", mods = "CMD", action = wezterm.action.ResetFontSize },
	{ key = "=", mods = "CMD", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
}

-- -- my coolnight colorscheme:
-- config.colors = {
-- 	foreground = "#CBE0F0",
-- 	background = "#011423",
-- 	cursor_bg = "#47FF9C",
-- 	cursor_border = "#47FF9C",
-- 	cursor_fg = "#011423",
-- 	selection_bg = "#033259",
-- 	selection_fg = "#CBE0F0",
-- 	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
-- 	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
-- }

-- and finally, return the configuration to wezterm
return config
