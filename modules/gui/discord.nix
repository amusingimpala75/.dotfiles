{
  inputs,
  ...
}:
{
  flake.modules.homeManager.discord = {
    imports = [
      "${inputs.home-manager}/modules/programs/discord.nix"
    ];

    programs.discord = {
      enable = true;
      configName = "org.nixos.discord";
    };

    nixpkgs.allowUnfreeList = [ "discord" ];
  };
}
