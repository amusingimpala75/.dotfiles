{
  self,
  ...
}:
{
  flake.darwinConfigurations = self.lib.mkDarwin "aarch64-darwin" "Lukes-Virutal-Machine" (
    {
      pkgs,
      ...
    }:
    {
      environment.shells = [ pkgs.zsh ];
      programs.zsh.enable = true;

      system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

      system.stateVersion = 4;
    }
  );
}
