{
  flake.modules.homeManager.ng-cli =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        sd
        tlrc
      ];
      programs = {
        bat = {
          enable = true;
          config.theme = "base16";
        };
        bottom.enable = true;
        eza = {
          enable = true;
          icons = "auto";
        };
        fd.enable = true;
        fzf.enable = true;
        ripgrep.enable = true;
        zoxide.enable = true;
      };
      services.tldr-update = {
        enable = true;
        package = pkgs.tlrc;
      };
    };
}
