{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.shells = with pkgs; [
    zsh
  ];

  programs.zsh.enable = true;

  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
  '';

  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

  # For backwards compatibility
  system.stateVersion = 4;
}
