{
  flake.modules.homeManager.brogue =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.brogue-ce ];
    };
}
