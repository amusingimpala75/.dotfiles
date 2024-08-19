{ self, config, pkgs, inputs, ... }:
let
in
{
  # TODO:
  # Decide if we want to eradicate all default references to the system's
  # ncurses 6.0 library, which cannot read the alacritty-direct generated
  # by nix's ncurses 6.4 library
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
