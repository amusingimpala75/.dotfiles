{
  flake.modules.nixos.hollowknight-login =
    {
      pkgs,
      ...
    }:
    let
      theme = "pixel-hollowknight";

      # [TODO] I need to fix the cursor, it's invisible atm
      package = pkgs.qylock-with-theme.override {
        inherit theme;
        hash = "sha256-1At9ffKV46lAOYn0ksyHPIzn8FUsHJfKuHcw4ep6vSs=";
      };
    in
    {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        inherit theme;
        package = pkgs.kdePackages.sddm;

        extraPackages = with pkgs.kdePackages; [
          package
          qtdeclarative
          qt5compat
          qtmultimedia
        ];
      };

      environment.systemPackages = [ package ];
    };
}
