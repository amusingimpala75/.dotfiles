(local sbar (require "sketchybar"))
(local defaults (require "defaults"))

(let [foreground (.. "0xff" defaults.base06)
      background (.. "0xff" defaults.base01)
      wksp-change-event "aerospace_workspace_change"
      spaces {}]
  (sbar.add "event" wksp-change-event)
  (fn space-changed [env]
    (let [name env.NAME
          index (. spaces name)
          is-focused (= index (tonumber env.FOCUSED_WORKSPACE))
          bg (if is-focused foreground background)
          fg (if is-focused background foreground)
          animate (lambda []
                    (sbar.set name {:background {:color bg}
                                    :icon {:color fg}
                                    :label {:color fg}}))]
      (sbar.animate "tanh" 15 animate)))
  (fn clicked [env]
    (let [name env.NAME
          index (. spaces name)]
      (sbar.exec (.. "~/.nix-profile/bin/aerospace workspace " (tonumber index)))))
  (for [i 1 9 1]
    (let [lb-pad (if (= i 1) defaults.bar-padding 0)
          rb-pad (if (= i 9) defaults.bar-padding 0)
          space (sbar.add "item" {:background {:color background
                                               ;; :height defaults.bar-height
                                               :padding_left lb-pad
                                               :padding_right rb-pad}
                                  :icon {:padding_left 0
                                         :padding_right 0}
                                  :label {:padding_left 10
                                          :padding_right 10
                                          :string (tonumber i)
                                          :color foreground}})]
      (space:subscribe wksp-change-event space-changed)
      (space:subscribe "mouse.clicked" clicked)
      (tset spaces space.name i)))
  (icollect [k _ (pairs spaces)]
    k))
