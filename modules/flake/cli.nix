{
  inputs,
  ...
}:
{
  flake.modules.homeManager.cli =
    {
      pkgs,
      ...
    }:
    {
      nixpkgs.overlays = [ inputs.bible.overlays.default ];

      home.packages = with pkgs; [
        bible.asv
        chafa
        doxx
        file
        jaq
        killall
        scc
        tree
        up
      ];
    };
}
