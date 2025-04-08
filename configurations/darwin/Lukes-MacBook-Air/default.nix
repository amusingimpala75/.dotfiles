{ self, config, pkgs, inputs, ... }:
let
  system = import ./system.nix;
in
{
  imports = [
    inputs.nix-rosetta-builder.darwinModules.default
  ];
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
