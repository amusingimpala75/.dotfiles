{
  self,
  ...
}:
{
  flake.modules.homeManager.vcs =
    {
      pkgs,
      ...
    }:
    {
      imports = with self.modules.homeManager; [
        gh
        tangled
      ];

      home.packages = with pkgs; [
        custom-jujutsu-weave
        custom-git
      ];
    };
}
