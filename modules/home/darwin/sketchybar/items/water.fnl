(local sbar (require "sketchybar"))
(local defaults (require "defaults"))

(var start (os.time))

(let [good (.. "0xff" defaults.base0D)
      bad (.. "0xff" defaults.base0F)
      duration (* 2.5 60)
      water (sbar.add "item" {:position "right"
                              :update_freq 10
                              :label {:string "⬤"
                                      :font {:style "Regular"
                                             :size 24}
                                      :color good}})]
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
