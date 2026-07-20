{
  inputs,
  self,
  ...
}:
{
  flake = {
    modules.homeManager.nurl = {
      imports = [ self.wrappers.nurl.install ];
      wrappers.nurl.enable = true;
    };

    wrappers = {
      nurl = {
        imports = [ self.wrapperModules.nurl-wrapper ];

        inherit (inputs) nixpkgs;
      };

      nurl-wrapper =
        {
          config,
          lib,
          pkgs,
          wlib,
          ...
        }:
        {
          imports = [ wlib.modules.default ];

          options.nixpkgs = lib.mkOption {
            type = lib.types.either lib.types.path lib.types.string;
            default = "<nixpkgs>";
          };

          config = {
            package = pkgs.nurl;
            flags."--nixpkgs" = config.nixpkgs;
          };
        };
    };
  };

  perSystem.wrappers.packages.nurl-wrapper = true;
}
