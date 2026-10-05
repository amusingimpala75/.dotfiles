{
  inputs,
  self,
  ...
}:
{
  flake.wrappers = {
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
}
