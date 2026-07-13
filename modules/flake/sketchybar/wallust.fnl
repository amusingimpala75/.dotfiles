(local fennel (require :fennel))
(collect [k v (pairs (fennel.dofile (.. (os.getenv "HOME") "/.config/sketchybar/colors.fnl")))]
  (values k (.. "0xff" (string.sub v 2))))
