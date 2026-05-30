(local sbar (require "sketchybar"))
(local defaults (require "defaults"))

(sbar.begin_config)

(local background-color (.. "0xff" defaults.base01))
(local border-width (/ defaults.border-width 4))

(sbar.default {:updates "when_shown"
               :label {:font (.. defaults.fixed-pitch ":Bold:" defaults.font-size)
                       :color (.. "0xff" defaults.base05)
                       :padding_left defaults.bar-padding
                       :padding_right defaults.bar-padding}
               :popup {:background {:color background-color
                                    :padding_left defaults.bar-padding
                                    :padding_right defaults.bar-padding
                                    :border_color (.. "0xff" defaults.active-border)
                                    :border_width border-width
                                    :corner_radius defaults.corner-radius}}
               :background {:color background-color
                            :corner_radius defaults.corner-radius
                            :height (- defaults.bar-height 8)}})

(sbar.bar {:height defaults.bar-height
           :color background-color
           :position (if defaults.bar-is-top "top" "bottom")
           :display "all"
           :corner_radius defaults.corner-radius
           :margin (* defaults.outer-gap 6)
           :y_offset (/ defaults.outer-gap 2)})

(fn mk-spacer [side]
  (sbar.add "item" {:position side :width 8 :background {:color "0x00000000"}}))

;; Left Items
(let [front-app (require "items.front_app")
      _spacer (mk-spacer "left")
      spaces (require "items.spaces")
      bracket-names spaces]
  (table.insert bracket-names front-app.name)
  (table.insert bracket-names _spacer.name)
  (sbar.add "bracket" bracket-names {:background {:height defaults.bar-height
                                                  :border_color (.. "0xCC" defaults.active-border)
                                                  :border_width border-width}}))

;; Right Items
(let [time (require "items.time")
      _spacer (mk-spacer "right")
      water (require "items.water")]
  (sbar.add "bracket" [time.name _spacer.name water.name] {:background {:height defaults.bar-height
                                                                        :border_color (.. "0xCC" defaults.active-border)
                                                                        :border_width border-width}}))

(sbar.end_config)

(sbar.event_loop)
