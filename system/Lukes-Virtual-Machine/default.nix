{ self, config, pkgs, inputs, ... }:
let
in
{
  environment.systemPackages = with pkgs; [
    alacritty
    emacs
    fastfetch
    jq
  ];

  environment.shells = with pkgs; [
    zsh
  ];

  fonts.packages = [ pkgs.iosevka ];

  services.emacs.enable = true;

  programs.zsh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.nix-daemon.enable = true;
  nixpkgs.hostPlatform = import ./system.nix;

  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
  '';

  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      orientation = "bottom";
      # persistent-apps = {
      #   "/"
      # };
    };
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
  };

  # For backwards compatibility
  system.stateVersion = 4;
}