; (local config ...)

(local wezterm (require "wezterm"))

(fn tset-many [...]
  {:fnl/docstring "Repeatedly set multiple entries in table."
   :fnl/arglist [t k v & more]}
  (let [[t k v & rest] [...]]
    (tset t k v)
    (if (> (length rest) 0)
        (tset-many t (table.unpack rest)))))

(fn mkFont [weight ?italic]
  "Generate a wezterm font with given weight."
  (wezterm.font config.fixed-pitch {:weight weight
                                    :italic (or ?italic nil)}))

(doto (wezterm.config_builder)
  (tset-many :window_padding {:left "3pt"
                              :right "3pt"
                              :top "5pt"
                              :bottom "5pt"}
             :color_scheme config.wezterm-theme
             :cursor_thickness 2.0
             :default_cursor_style "BlinkingBar"
             :cursor_blink_rate 500
             :hide_tab_bar_if_only_one_tab true
             :window_decorations "RESIZE"
             :font (mkFont "Light")
             :font_size config.font-size
             :bold_brightens_ansi_colors true
             :dpi 144.0
             :font_rules [{:intensity "Bold" :font (mkFont "ExtraBold")}
                          {:intensity "Bold" :italic true :font (mkFont "ExtraBold" true)}
                          {:italic true :font (mkFont "Medium" true)}]
             :harfbuzz_features ["calt=1" "clig=1" "liga=1" "dlig=1"]
             :automatically_reload_config true
             :check_for_updates false
             :adjust_window_size_when_changing_font_size false
             :window_background_opacity config.opacity
             :macos_window_background_blur 20))
