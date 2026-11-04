{
  flake.wrappers.nix-update =
    {
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      package = pkgs.nix-update;
      env.NIX_PATH = "nixpkgs=flake:nixpkgs";
      flags."-u" = true;
      flags."--flake" = true;
    };
}
