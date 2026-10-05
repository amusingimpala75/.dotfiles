{
  flake.wrappers.foot =
    {
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.foot ];
      settings = {
        main = {
          dpi-aware = true;
          font = "Maple Mono NF CN:size=16,Noto Color Emoji:size=16";
          gamma-correct-blending = true;
          include = "~/.config/foot/foot.ini";
        };
      };
    };
}
