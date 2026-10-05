{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.murrayle23 = {
    imports = [ self.modules.nixos.home-manager ];

    home-manager.users.murrayle23 = {
      imports = self.homeConfigurations.murrayle23.config._rootModules;
    };

    wsl.defaultUser = "murrayle23";
  };

  flake.homeConfigurations = self.lib.mkHome "x86_64-linux" "murrayle23" (
    {
      pkgs,
      ...
    }:
    {
      imports = with self.modules.homeManager; [
        cli
        cloudflare-manager
        direnv
        emacs
        git
        jujutsu
        ng-cli
        ng-nix
        pi
        ssh
        vcs
        wallust
        wsl
        zsh

        "${inputs.home-manager}/modules/services/podman"
        "${inputs.home-manager}/modules/programs/foot.nix"
        "${inputs.home-manager}/modules/programs/noctalia"
      ];

      vcs = {
        email = "69653100+amusingimpala75@users.noreply.github.com";
        username = "amusingimpala75";
      };

      wsl.username = "MURRAYLE23";

      services.podman.enable = true;
      programs.foot.enable = true;
      programs.noctalia.enable = true;
      programs.noctalia.package = pkgs.custom-noctalia;

      home.packages = with pkgs; [
        noto-fonts-color-emoji
        get-win-sid
        # [TODO] switch back to bleeding (i.e. module) once no longer broken on weaselway
        ladybird
        play-audio
        wsl-open

        inputs.automader.packages.${pkgs.stdenv.hostPlatform.system}.automader
      ];

      home.stateVersion = "26.05";
    }
  );

  flake-file.inputs.automader = {
    url = "github:amusingimpala75/automata_grader";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
