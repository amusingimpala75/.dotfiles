{
  flake.modules.nixos.sshfs =
    {
      pkgs,
      ...
    }:
    {
      programs.fuse.enable = true;
      environment.systemPackages = [ pkgs.sshfs ];
    };
}
