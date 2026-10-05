{
  inputs,
  ...
}:
{
  flake.modules.homeManager.ghostty =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        "${inputs.home-manager}/modules/programs/ghostty.nix"
        "${inputs.home-manager}/modules/programs/vim.nix"
      ];

      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.hostPlatform.isLinux then pkgs.ghostty else pkgs.ghostty-bin;
        settings = {
          background-opacity = "0.9";

          font-family = "Maple Mono NF CN";
          font-size = "16";

          config-file = toString ./config.ghostty;
        };
      };

      home.packages = [ pkgs.maple-mono.NF-CN-unhinted ];

      home.file.".hushlogin" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin { text = ""; };
    };
}
