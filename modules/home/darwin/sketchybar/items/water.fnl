(local sbar (require "sketchybar"))
(local defaults (require "defaults"))
(local wallust (require "wallust"))

(var start (os.time))

(let [good wallust.base06
      bad wallust.base03
      duration (* 2.5 60)
      water (sbar.add "item" {:position "right"
                              :update_freq 10
                              :label {:string "⬤"
                                      :font {:style "Regular"
                                             :size 24}
                                      :color good
                                      }
                              :background {:padding_left defaults.bar-padding}})]
  (fn should-drink []
    (> (os.difftime (os.time) start) duration))

  (fn drink []
    (set start (os.time))
    (water:set {:label {:color good}}))

  (fn check-drink []
    (when (should-drink)
      (water:set {:label {:color bad}})))

  (doto water
    (: :subscribe "mouse.clicked" drink)
    (: :subscribe "routine" check-drink)
    (: :subscribe "forced" check-drink))

  water)
