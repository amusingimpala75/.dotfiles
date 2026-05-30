{
  inputs,
  ...
}:
{
  flake.modules.homeManager.hister = {
    imports = [ inputs.hister.homeModules.default ];
    services.hister.enable = true;
  };

  flake-file.inputs.hister = {
    url = "github:asciimoo/hister";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
