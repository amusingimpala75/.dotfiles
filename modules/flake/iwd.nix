{
  flake.modules.nixos.iwd = {
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";
  };
}
