{
  fd,
  fzf,
  lib,
  scriptWrapper,
  ...
}:
scriptWrapper "launcher" [
  fd
  fzf
] // {
  meta = {
    description = "Simple fzf-based launcher for macOS";
    platforms = lib.platforms.darwin;
  };
}
