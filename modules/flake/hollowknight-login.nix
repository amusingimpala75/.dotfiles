{
  flake.modules.nixos.hollowknight-login =
    {
      pkgs,
      ...
    }:
    let
      theme-name = "pixel-hollowknight";

      theme = pkgs.stdenv.mkDerivation {
        name = "sddm-theme-${theme-name}";
        src = pkgs.fetchFromGitHub {
          owner = "Darkkal44";
          repo = "qylock";
          rev = "3ecb79f621d5bfc2fbc6bfd37c3b12f0214601ac";
          hash = "";
          sparseCheckout = [
            "themes/${theme-name}"
          ];
        };

        installPhase = ''
          mkdir -p $out/share/sddm/themes/${theme-name}"
          cp -r themes/pixel-hollowknight/. $out/share/sddm/themes/${theme-name}
        '';
      };
    in
    {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = theme-name;
        package = pkgs.kdePackages.sddm;

        extraPackages = with pkgs.kdePackages; [
          theme
          qtdeclarative
          qt5compat
          qtmultimedia
        ];
      };

      environment.systemPackages = [ theme ];
    };
}
