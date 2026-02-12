{
  config,
  lib,
  pkgs,
  ...
}:
let
  format = pkgs.formats.toml { };

  is-extension = str: lib.strings.hasPrefix "." str;
  is-scheme = str: lib.strings.hasSuffix "://" str;

  clean-name =
    str:
    if is-extension str then
      lib.substring 1 (-1) str
    else if is-scheme str then
      lib.substring 0 ((builtins.stringLength str) - 3) str
    else
      str;

  list-of-mappings = lib.flatten (
    lib.mapAttrsToList (
      name: value:
      lib.lists.map (val: {
        name = val;
        value = name;
      }) value
    ) config.infat.associations
  );

  association-type =
    str:
    if is-extension str then
      "extensions"
    else if is-scheme str then
      "schemes"
    else
      "types";

  grouped = lib.groupBy (set: association-type set.name) list-of-mappings;

  infat-config = format.generate "infat-config" (
    builtins.mapAttrs (
      name: val:
      builtins.listToAttrs (
        lib.map (
          value:
          value
          // {
            name = clean-name value.name;
          }
        ) val
      )
    ) grouped
  );

  infat-config-reset = format.generate "infat-config-reset" (
    builtins.mapAttrs (
      name: val:
      builtins.listToAttrs (
        lib.map (value: {
          name = clean-name value.name;
          value = "TextEdit";
        }) val
      )
    ) grouped
  );
in
{
  options.infat = {
    enable = lib.mkEnableOption "infat file association control";
    associations = lib.mkOption {
      default = { };
      example = ''{ "Emacs" = [ ".org", ".el" }'';
      description = ''
        File association to make with infat.
        staring with '.' (e.g. .json) is interpreted as an extension
        ending in '://' (e.g. mailto://) is interpreted as a scheme
        anything else is a type.'';
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    };
  };

  config.home.activation.infat-set-associations =
    lib.mkIf (pkgs.stdenv.isDarwin && config.infat.enable)
      (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${lib.getExe pkgs.infat} -c ${infat-config-reset}
          ${lib.getExe pkgs.infat} -c ${infat-config}
        ''
      );
}
