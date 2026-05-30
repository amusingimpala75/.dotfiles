(local sbar (require "sketchybar"))
(local defaults (require "defaults"))
(local rift (require "rift"))

(local client (let [[client err] [(rift.connect)]]
                (when (not client)
                  (error err))
                client))

(let [foreground (.. "0xff" defaults.base06)
      background (.. "0xff" defaults.base01)
      spaces []]
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
      (fn space-changed [env]
        (let [is-focused (= i (tonumber env.DATA.workspace_id.idx))
              bg (if is-focused foreground background)
              fg (if is-focused background foreground)
              animate (lambda []
                        (sbar.set space.name {:background {:color bg}
                                              :icon {:color fg}
                                              :label {:color fg}}))]
          (sbar.animate "tanh" 15 animate)))
      (fn clicked [_]
        ;; [TODO] switch to using the rift client object from above
        (sbar.exec (.. "~/.nix-profile/bin/rift-cli execute workspace switch " (tonumber (- i 1)))))

      (client:subscribe ["workspace_changed"] space-changed)
      (space:subscribe "mouse.clicked" clicked)
      (table.insert spaces space.name)))
  spaces)
