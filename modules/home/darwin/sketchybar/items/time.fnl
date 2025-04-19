(local sbar (require "sketchybar"))

(fn set-popup [item on]
  (doto item
    (: :set {:popup {:drawing (if on "on" "off")}})))

(let [time-item (sbar.add "item" {:position "right"
                                  :update_freq 1
                                  :popup {:align "center"}})
      date-item (sbar.add "item" {:position (.. "popup." time-item.name)
                                  :update_freq 60})]
  (doto time-item
    (: :subscribe "routine" (lambda []
                              (time-item:set {:label {:string (os.date "%H:%M:%S")}})))
    (: :subscribe "mouse.entered" (lambda []
                                    (set-popup time-item true)))
    (: :subscribe "mouse.exited" (lambda []
                                   (set-popup time-item false)))
    (: :subscribe "mouse.exited.global" (lambda []
                                          (set-popup time-item false))))
  (fn date-update []
    (date-item:set {:label {:string (os.date "%a %d %b")}}))
  (doto date-item
    (: :subscribe "routine" date-update)
    (: :subscribe "forced" date-update)
    (: :subscribe "mouse.clicked" (lambda []
                                    (set-popup time-item false)
                                    (os.execute "open -a \"Calendar\"")))))
