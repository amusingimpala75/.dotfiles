local config = wezterm.config_builder()

config.window_padding = {
  left = '3pt',
  right = '3pt',
  top = '5pt',
  bottom = '5pt',
}

config.color_scheme = "Gruvbox Dark (Gogh)"

config.cursor_thickness = 2.0
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
--config.window_background_opacity = 0.92
--config.macos_window_background_blur = 20

local font_family = "Iosevka"

config.font = wezterm.font(font_family, {weight = "Light"})
config.font_size = 16.0
config.bold_brightens_ansi_colors = true
config.dpi = 144.0
config.font_rules = {
  {
    intensity = "Bold",
    font = wezterm.font(font_family, {weight = "ExtraBold"})
  },
  {
    italic = true,
    intensity = "Bold",
    font = wezterm.font(font_family, {italic = true, weight = "ExtraBold"})
  },
  {
    italic = true,
    font = wezterm.font(font_family, {italic = true, weight = "Medium"})
  },
}

config.harfbuzz_features = {"calt=1", "clig=1", "liga=1"}
config.automatically_reload_config = true
config.check_for_updates = false

config.adjust_window_size_when_changing_font_size = false

return config
