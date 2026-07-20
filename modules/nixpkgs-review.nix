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
        # Mostly copied from nixpkgs-reviewFull,
        # but add our wrapped delta
        package = pkgs.nixpkgs-review.override {
          withSandboxSupport = pkgs.stdenv.hostPlatform.isLinux;
          withNom = true;
          withDelta = true;
          withGlow = true;
          inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) delta;
        };
        flags."--systems" = "all";
      };
    };
}
