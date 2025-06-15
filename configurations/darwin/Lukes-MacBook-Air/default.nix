{ pkgs, ... }:
{
  environment.shells = with pkgs; [
    zsh
  ];

  programs.zsh.enable = true;

  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  # For backwards compatibility
  system.stateVersion = 5;
}
