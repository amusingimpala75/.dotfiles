{
  inputs,
  ...
}:
{
  flake.modules.homeManager.discord = {
    imports = [
      "${inputs.home-manager}/modules/programs/discord.nix"
    ];

    # On switch, nix-darwin may fail on macOS 27 or later
    # when it tries to write the settings. Go to Settings
    # -> Privacy & Security -> Files & Folders -> <Your Terminal>
    # and give it access to Discord's app data folder
    programs.discord.enable = true;

    nixpkgs.allowUnfreeList = [ "discord" ];
  };
}
