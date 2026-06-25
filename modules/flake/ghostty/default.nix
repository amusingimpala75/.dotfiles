{
  flake.modules.homeManager.ghostty =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.isLinux then pkgs.ghostty else pkgs.ghostty-bin;
        settings = with config.rice; {
          background-opacity = "${toString opacity}";

          font-family = "${toString font.family.fixed-pitch}";
          font-size = "${toString font.size}";

          config-file = toString ./config.ghostty;
        };
      };

      home.file.".hushlogin".text = lib.mkIf pkgs.stdenv.isDarwin "";
    };
}
