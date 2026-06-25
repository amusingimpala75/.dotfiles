{
  self,
  ...
}:
{
  flake.wrappers.nixpkgs-review =
    {
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];
      config = {
        package = pkgs.symlinkJoin {
          name = pkgs.nixpkgs-review.name;
          paths = with pkgs; [
            glow
            nixpkgs-review
            nom
            self.packages.${pkgs.stdenv.hostPlatform.system}.delta
          ];
        };
        flags."--systems" = "all";
      };
    };
}
