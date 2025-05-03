{ pkgs, ... }:
{
  environment.shells = with pkgs; [
    zsh
  ];

  programs.zsh.enable = true;

  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
  '';

  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  # For backwards compatibility
  system.stateVersion = 5;
}
