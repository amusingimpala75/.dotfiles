{
  inputs,
  self,
  ...
}:
{
  flake.homeManagerModules.breaktime =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.services.breaktime = {
        enable = lib.mkEnableOption "breaktime time management";
        package =
          lib.mkPackageOption inputs.breaktime.packages.${pkgs.stdenv.hostPlatform.system} "default"
            { };
        settings = lib.mkOption {
          type = lib.types.nullOr lib.types.json;
          description = "breaktime settings";
          default = null;
        };
      };

      config = lib.mkIf config.services.breaktime.enable {
        launchd.agents.breaktime = {
          enable = true;
          config = {
            ProgramArguments = [
              "/usr/bin/env"
              "sh"
              "-c"
              "sleep 5; ${lib.getExe config.services.breaktime.package}"
            ];
            RunAtLoad = true;
            # I'm worried that I could accidentally live lock this, wouldn't be ideal
            # so that's why I have the 'sleep 5'
            KeepAlive = true;
          };
        };
      };
    };

  flake.modules.homeManager.breaktime = {
    imports = [ self.homeManagerModules.breaktime ];
    services.breaktime.enable = true;
    # settings TODO once proper theming support is actually working
  };
}
