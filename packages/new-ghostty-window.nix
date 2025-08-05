{
  lib,
  ripgrep,
  scriptWrapper,
  ...
}:
(scriptWrapper "new-ghostty-window" [ ripgrep ]).overrideAttrs (old: {
  meta = {
    platforms = lib.platforms.darwin;
  };
})
