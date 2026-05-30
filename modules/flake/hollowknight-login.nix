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

  flake-file.inputs.qylock = {
    url = "github:LordHerdier/qylock-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
