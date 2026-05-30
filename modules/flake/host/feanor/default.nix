{
  self,
  ...
}:
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "feanor" {
    imports =
      with self.modules.generic;
      with self.modules.nixos;
      [
        broadcom-wifi
        iwd
        feanor-disko
        impermanence
        # [TODO] add persisting some folders with impermanence
        btrfs-rollback
        ram-compression
        hollowknight-login
        amusingimpala75
      ];
    boot.btrfs-rollback.device = "/dev/mapper/crypted";
    hardware.facter.reportPath = ./hardware.json;
    services.desktopManager.cosmic.enable = true;
    programs.zsh.enable = true;
    boot.loader.systemd-boot.enable = true;
    system.stateVersion = "26.05";
  };
}
