{
  inputs,
  ...
}:
{
  imports = [ inputs.flake-file.flakeModules.default ];
  flake-file = {
    inputs.flake-file.url = "github:denful/flake-file";
    outputs = ''
      inputs:
      inputs.flake-parts.lib.mkFlake { inherit inputs; } (
        {
          lib,
          ...
        }:
        {
          # Custom import-tree courtesy of iampavel.dev
          imports = lib.fileset.toList (
            lib.fileset.fileFilter (file: file.hasExt "nix" && !(lib.hasPrefix "_" file.name)) ./modules
          );
        }
      )
    '';

    description = "My system configurations for macOS, WSL, and NixOS";
  };
}
