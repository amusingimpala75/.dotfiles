{
  config,
  ...
}:
let
  darwinModules = config.flake.modules.darwin or { };
  genericModules = config.flake.modules.generic or { };
  homeModules = config.flake.modules.home or { };
  nixosModules = config.flake.modules.nixos or { };
in
{
  flake = {
    darwinModules = darwinModules // genericModules;
    homeModules = homeModules // genericModules;
    nixosModules = nixosModules // genericModules;
  };
}
