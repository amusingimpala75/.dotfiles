{
  flake.modules.nixos.broadcom-wifi =
    {
      config,
      ...
    }:
    {
      nixpkgs.allowUnfreeList = [ "broadcom-sta" ];
      nixpkgs.config.permittedInsecurePackages = [
        config.boot.kernelPackages.broadcom_sta.name
      ];
      boot = {
        extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        kernelModules = [ "wl" ];
        blacklistedKernelModules = [
          "b43"
          "ssb"
          "bcma"
        ];
      };
    };
}
