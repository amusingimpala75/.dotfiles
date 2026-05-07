{
  inputs,
  ...
}:
{
  flake.modules.nixos.hollowknight-login = {
    imports = [ inputs.qylock.nixosModules.default ];
    programs.qylock = {
      enable = true;
      theme = "pixel-hollowknight";
      sddmTheme = "pixel-hollowknight";
    };
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
