{
  flake.wrappers.jankyborders =
    {
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      package = pkgs.jankyborders;

      flags = {
        "style=round" = true;
        "width=${toString 8}" = true;
        "active_color=0xffffffff" = true;
        "inactive_color=0x00000000" = true;
      };

      meta.platforms = lib.platforms.darwin;
    };
}
