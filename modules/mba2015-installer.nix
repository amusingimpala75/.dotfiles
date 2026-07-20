{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.mba2015-installer = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules =
      with self.modules.generic;
      with self.modules.nixos;
      [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
        nixpkgs
        broadcom-wifi
        iwd
      ];
  };
  flake.packages.x86_64-linux.mba2015-installer =
    self.nixosConfigurations.mba2015-installer.config.system.build.isoImage;
}
