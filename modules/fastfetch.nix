{
  flake.wrappers.fastfetch =
    {
      config,
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.fastfetch ];
      aliases = [ "neofetch" ];
      settings = "${config.package.passthru.unwrapped.src}/presets/examples/13.jsonc"
        |> builtins.readFile
        |> builtins.split "\n"
        |> builtins.filter builtins.isString
        |> map (line: line |> builtins.split "(^|[[:space:]]+)//.*" |> builtins.head)
        |> builtins.concatStringsSep ""
        |> builtins.fromJSON;
    };
}
