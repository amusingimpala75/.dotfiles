{
  flake.modules.homeManager.ladybird =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.bleeding.ladybird ];
    };
}
