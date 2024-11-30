# lower portion courtesy of r17x at https://github.com/r17x/universe
{ lua54Packages, lib, writeText, userSettings, ... }:

let
  inherit (lua54Packages) lua buildLuaPackage;
  defaults = writeText "defaults.lua" (with userSettings;
  ''
    return {
      bar = {
        height = ${toString bar.height},
        position = '${if bar.isTop then "top" else "bottom"}',
      },
      font = {
        fixed = '${font.family.fixed-pitch}',
        variable = '${font.family.variable-pitch}',
        size = ${toString font.size},
      },
      theme = {
        base00 = '0xff${theme.base00}',
        base01 = '0xff${theme.base01}',
        base02 = '0xff${theme.base02}',
        base03 = '0xff${theme.base03}',
        base04 = '0xff${theme.base04}',
        base05 = '0xff${theme.base05}',
        base06 = '0xff${theme.base06}',
        base07 = '0xff${theme.base07}',
        base08 = '0xff${theme.base08}',
        base09 = '0xff${theme.base09}',
        base0A = '0xff${theme.base0A}',
        base0B = '0xff${theme.base0B}',
        base0C = '0xff${theme.base0C}',
        base0D = '0xff${theme.base0D}',
        base0E = '0xff${theme.base0E}',
        base0F = '0xff${theme.base0F}',
      },
    }
  '');
in

buildLuaPackage {
  name = "sketchybar-config";
  pname = "sketchybar-config";
  version = "0.0.0";
  src = lib.cleanSource ./.;
  buildPhase = ":";
  installPhase = # bash
    ''
      mkdir -p "$out/share/lua/${lua.luaversion}"
      cp -r $src/* "$out/share/lua/${lua.luaversion}/"
      cp ${defaults} "$out/share/lua/${lua.luaversion}/defaults.lua"
    '';
}
