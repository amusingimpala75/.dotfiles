{ self, config, pkgs, inputs, ... }:
let
in
{
  environment.systemPackages = with pkgs; [
  ];

  environment.shells = with pkgs; [
    zsh
  ];

  programs.zsh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixVersions.nix_2_20;
  nixpkgs.hostPlatform = import ./system.nix;

  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
  '';

  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

   # For backwards compatibility
  system.stateVersion = 4;
}
