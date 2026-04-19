{
  flake.modules.nixos.broadcom-wifi =
    {
      config,
      ...
    }:
    {
      nixpkgs.allowUnfreeList = [ "broadcom-sta" ];
      nixpkgs.config.permittedInsecurePackages = [
        "broadcom-sta-6.30.223.271-59-${config.boot.kernelPackages.kernel.version}"
      ];
      boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
      boot.kernelModules = [ "wl" ];
      boot.blacklistedKernelModules = [
        "b43"
        "ssb"
        "bcma"
      ];
    };
}
