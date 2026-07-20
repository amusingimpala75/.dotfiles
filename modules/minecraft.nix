{
  flake.modules.homeManager.minecraft =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.prismlauncher ];
    };
}
