{
  flake.modules.nixos.ram-compression = {
    boot.zswap.enable = true;
  };
}
