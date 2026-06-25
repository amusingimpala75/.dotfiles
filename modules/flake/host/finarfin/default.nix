{
  self,
  ...
}:
{
  flake.darwinConfigurations = self.lib.mkDarwin "aarch64-darwin" "finarfin" (
    {
      pkgs,
      ...
    }:
    {
      imports = with self.modules.darwin; [
        brew
        dictionary
        lukemurray
        user-applications
      ];

      environment.shells = [ pkgs.zsh ];

      programs.zsh.enable = true;

      system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

      security.pam.services.sudo_local = {
        enable = true;
        touchIdAuth = true;
      };

      system.stateVersion = 5;
    }
  );
}
