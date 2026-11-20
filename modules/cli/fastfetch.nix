{
  flake.wrappers.fastfetch =
    {
      config,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];
      aliases = [ "neofetch" ];
      package = pkgs.fastfetch;
      flags."--config" = "${config.package.passthru.unwrapped.src}/presets/examples/13.jsonc";
    };
}
