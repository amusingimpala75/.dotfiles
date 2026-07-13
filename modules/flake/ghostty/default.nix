{
  flake.modules.homeManager.ghostty =
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.isLinux then pkgs.ghostty else pkgs.ghostty-bin;
        settings = {
          background-opacity = "0.9";

          font-family = "Maple Mono NF CN";
          font-size = "16";

          config-file = toString ./config.ghostty;
        };
      };

      home.packages = [ pkgs.maple-mono.NF-CN-unhinted ];

      home.file.".hushlogin".text = lib.mkIf pkgs.stdenv.isDarwin "";
    };
}
