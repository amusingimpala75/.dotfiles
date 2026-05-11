{
  self,
  ...
}:
{
  flake.homeConfigurations = self.lib.mkHome "x86_64-linux" "murrayle23" (
    {
      lib,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = with self.modules.homeManager; [
        brogue
        direnv
        emacs
        ng-cli
        ng-nix
        pi
        wallpaper
        wallust
        wsl
      ];

      my = {
        cli.enable = true;
        vcs = {
          git = true;
          jujutsu = true;
          email = "69653100+amusingimpala75@users.noreply.github.com";
          username = "amusingimpala75";
        };
      };

      rices.nord.enable = true;
      rice.font.size = lib.mkForce 20;

      wsl.username = "MURRAYLE23";

      services.podman.enable = true;

      home.packages = with pkgs; [
        noto-fonts-color-emoji
        get-win-sid
        play-audio
        wsl-open

        inputs.automader.packages.${pkgs.stdenv.hostPlatform.system}.automader

        (dyalog.override { acceptLicense = true; })
        ride
      ];

      nixpkgs.allowUnfreeList = [ "dyalog" ];

      home.stateVersion = "24.05";
    }
  );
}
