(local sbar (require "sketchybar"))
(local defaults (require "defaults"))

(let [char-width 9
      nchars 10
      front-app (sbar.add "item" {:position "left"
                                  :background {:padding_left defaults.bar-padding}
                                  :icon {:drawing false}
                                  :scroll_texts "on"
                                  :label {:width (* char-width nchars)
                                          :max_chars nchars}})]
  (front-app:subscribe "front_app_switched" (lambda [env]
                                              (front-app:set {:label {:string env.INFO}})))

  front-app)
