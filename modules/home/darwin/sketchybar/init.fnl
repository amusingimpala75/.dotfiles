(local sbar (require "sketchybar"))
(local defaults (require "defaults"))

(sbar.begin_config)

(local background-color (.. "0xff" defaults.base01))

(sbar.default {:updates "when_shown"
               :label {:font (.. defaults.fixed-pitch ":Bold:" defaults.font-size)
                       :color (.. "0xff" defaults.base05)
                       :padding_left defaults.padding
                       :padding_right defaults.padding}
               :popup {:background {:color background-color
                                    :padding_left defaults.padding
                                    :padding_right defaults.padding
                                    :border_color (.. "0xff" defaults.active-border)
                                    :border_width (/ defaults.border-width 2)}}})

(sbar.bar {:height defaults.bar-height
           :color background-color
           :position (if defaults.bar-is-top "top" "bottom")
           :display "all"})

;; Left Items
(require "items.front_app")
(require "items.spaces")

;; Right Items
(require "items.time")
(require "items.water")

(sbar.end_config)

(sbar.event_loop)
