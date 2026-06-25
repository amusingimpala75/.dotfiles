{
  lib,
  self,
  ...
}:
let
  darwin = pkgs: {
    launchd.agents.neko = {
      enable = true;
      config = {
        ProgramArguments = [ (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.custom-neko-go) ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
  nixos = { };
in
{
  flake.modules.homeManager.neko =
    {
      pkgs,
      ...
    }:
    lib.mkMerge [
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (darwin pkgs))
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux nixos)
    ];

  flake.wrappers.custom-neko-go =
    {
      pkgs,
      ...
    }:
    {
      imports = [ self.wrapperModules.neko-go-wrapper ];
      speed = 3.0;
      scale = 1.25;
      quiet = true;
      passthrough = true;
      skin = pkgs.neko-go.skins.maria;
    };

  flake.wrappers.neko-go-wrapper =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      options = {
        speed = lib.mkOption {
          type = lib.types.float;
          default = 2.0;
        };
        scale = lib.mkOption {
          type = lib.types.float;
          default = 2.0;
        };
        quiet = lib.mkEnableOption "suppress noises";
        passthrough = lib.mkEnableOption "mouse click passthrough";
        skin = lib.mkOption {
          type = lib.types.path;
          default = pkgs.neko-go.skins.default;
        };
      };

      config = {
        package = pkgs.neko-go;
        flags = {
          "-speed" = toString config.speed;
          "-scale" = toString config.scale;
          "-spritesheet" = config.skin;
        };
        addFlag =
          (lib.optionals config.quiet [ "-quiet" ])
          ++ (lib.optionals config.passthrough [ "-mousepassthrough" ]);
      };
    };
  perSystem.wrappers.packages.neko-go-wrapper = true;
}
