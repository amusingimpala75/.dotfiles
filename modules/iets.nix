{
  inputs,
  ...
}:
{
  flake.modules.homeManager.iets =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ inputs.iets.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };

  flake-file.inputs.iets = {
    url = "github:numtide/iets";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
