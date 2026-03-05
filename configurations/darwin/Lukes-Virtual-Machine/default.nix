{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.shells = with pkgs; [
    zsh
  ];

  programs.zsh.enable = true;

  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

  # For backwards compatibility
  system.stateVersion = 4;
}
