{ lib, config, pkgs, username, hostname, dotfilesDir, ... }:
{
  home.shellAliases = {
    reload-hm = "home-manager switch -b --flake ${dotfilesDir}#${username}_${hostname}";
    reload-nd = if pkgs.stdenv.isDarwin then "darwin-rebuild switch --flake ${dotfilesDir}" else "echo 'Did you mean reload-no?'";
    reload-no = if pkgs.stdenv.isLinux  then "nixos-rebuild  switch --flake ${dotfilesDir}" else "echo 'Did you mean reload-nd?'";
    reload-config = if pkgs.stdenv.isLinux then "reload-no && reload-hm" else "reload-nd && reload-hm";
  };
}
