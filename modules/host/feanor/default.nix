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
        amusingimpala75
        nnn-stack
      ];

    services.displayManager.noctalia-greeter.passwordlessSyncUsers = [ "amusingimpala75" ];
    boot.btrfs-rollback.device = "/dev/mapper/crypted";
    hardware.facter.reportPath = ./hardware.json;
    programs.zsh.enable = true;
    boot.loader.systemd-boot.enable = true;
    system.stateVersion = "26.05";
  };
}
