{
  inputs,
  lib,
  ...
}:
let
  withSubstituters =
    yes:
    {
      pkgs,
      ...
    }:
    {
      nix.package = inputs.determinate-nix-cli.packages.${pkgs.stdenv.hostPlatform.system}.nix-cli;
      nix.settings.trusted-substituters = lib.mkIf yes [ "https://install.determinate.systems" ];
      nix.settings.trusted-public-keys = lib.mkIf yes [
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      ];
    };
in
{
  flake.modules.darwin.determinate-nix = withSubstituters true;
  flake.modules.homeManager.determinate-nix = withSubstituters false;
  flake.modules.nixos.determinate-nix = withSubstituters true;

  flake-file.inputs.determinate-nix-cli.url = "github:DeterminateSystems/nix-src";
}
