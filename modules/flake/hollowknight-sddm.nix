{
  flake.modules.nixos.hollowknight-sddm =
    {
      pkgs,
      ...
    }:
    {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "pixelart-hollowknight";
      };
      environment.systemPackages = [
        pkgs.sddm-pixelart-hollowknight
      ];
      fonts.packages = [
        pkgs.sddm-pixelart-hollowknight.fonts
      ];
    };
}
