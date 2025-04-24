{ pkgs, ... }:
let
  system = import ./system.nix;
in
{
  environment.shells = with pkgs; [
    zsh
  ];

  programs.zsh.enable = true;

  nixpkgs.hostPlatform = system.arch;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
  '';

  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

  nix.linux-builder.enable = true;
  nix-rosetta-builder.onDemand = true;

  # For backwards compatibility
  system.stateVersion = 5;
}
