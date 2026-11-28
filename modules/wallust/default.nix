{
  inputs,
  ...
}:
{
  flake.modules.homeManager.wallust =
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
    {
      imports = [
        # "${inputs.home-manager}/modules/programs/bat.nix"
        # "${inputs.home-manager}/modules/programs/fish.nix"
        # "${inputs.home-manager}/modules/programs/ghostty.nix"
        # "${inputs.home-manager}/modules/programs/man"
        # "${inputs.home-manager}/modules/programs/vim.nix"
        "${inputs.home-manager}/modules/programs/wallust.nix"
      ];

      programs.wallust = {
        enable = true;
        settings = {
          palette = "softdark16";
          check_contrast = true;
          templates = {
            # Really can be replaced with a templated_hook,
            # waiting for that to be properly released in 4.0
            palette = {
              template = ./palette.wallust;
              target = "~/.local/state/wallust/palette.txt";
            };
            # Same here
            wallpaper = {
              template = ./wallpaper.wallust;
              target = "~/.local/state/wallust/wallpaper.txt";
            };
          };
          hooks = {
            wallpaper =
              if pkgs.stdenv.hostPlatform.isDarwin then
                ''${lib.getExe pkgs.desktoppr} "$(cat ~/.local/state/wallust/wallpaper.txt)"''
              else if (options ? wsl) then
                ''
                  cp "$(cat ~/.local/state/wallust/wallpaper.txt)" 'C:\Users\${config.wsl.username}\.nix-profiles\share\wallpaper.png'
                  ${lib.getExe pkgs.wallp} 'C:\Users\${config.wsl.username}\.nix-profile\share\wallpaper.png
                ''
              else
                ""; # [TODO]
          };
        };
      };
    };
}
