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
        direnv
        cli
        emacs
        git
        jujutsu
        ng-cli
        ng-nix
        pi
        vcs
        wallust
        wsl
        zsh
      ];

      vcs = {
        email = "69653100+amusingimpala75@users.noreply.github.com";
        username = "amusingimpala75";
      };

      wsl.username = "MURRAYLE23";

      services.podman.enable = true;

      home.packages = with pkgs; [
        noto-fonts-color-emoji
        get-win-sid
        play-audio
        wsl-open

        inputs.automader.packages.${pkgs.stdenv.hostPlatform.system}.automader
      ];

      home.stateVersion = "24.05";
    }
  );

  flake-file.inputs.automader = {
    url = "github:amusingimpala75/automata_grader";
    inputs.nixpkgs.follows = "nixpkgs";
  };

}
