{
  inputs,
  ...
}:
{
  flake.modules.nixos.wsl = {
    imports = [ inputs.nixos-wsl.nixosModules.default ];
    wsl.enable = true;
    wsl.startMenuLaunchers = true;
  };
}
