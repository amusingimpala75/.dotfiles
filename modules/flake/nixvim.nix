{
  self,
  ...
}:
{
  flake.overlays.nixvim = final: prev: {
    my-nvim =
      self.nixvimConfigurations.${final.stdenv.hostPlatform.system}.nixvim.config.build.package.overrideAttrs
        (old: {
          meta = old.meta // {
            description = "my neovim configuration";
            mainProgram = "nvim";
          };
        });
  };
  nixvim = {
    # We have to manually override with pname and description
    packages.enable = false;
    checks.enable = true;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.nixvim = pkgs.my-nvim;
    };
}
