{
  inputs,
  ...
}:
{
  flake.modules.nixos.weaselway =
    {
      pkgs,
      ...
    }:
    {
      imports = [ inputs.weaselway.nixosModules.weaselway ];

      weaselway = {
        enable = true;
        session = "custom";
      };

      nixpkgs.overlays = [
        (final: prev: {
          weaselway-scripts = prev.weaselway-scripts.overrideAttrs (old: {
            buildCommand = old.buildCommand + ''
              wrapProgram $out/bin/ww-start-viewer --add-flags '/sec:tls'
            '';
            nativeBuildInputs = [ final.makeWrapper ];
          });
        })
      ];

      environment.systemPackages = [
        (pkgs.writeShellApplication {
          name = "custom-weaselway-session";
          text = ''
            export XDG_CURRENT_DESKTOP=niri
            exec niri --session "$@"
          '';
          runtimeInputs = [
            (pkgs.custom-niri.wrap {
              settings = {
                debug = {
                  render-drm-device = "/dev/dri/renderD129";
                };
              };
            })
          ];
        })
      ];
    };

  flake-file.inputs.weaselway = {
    url = "github:weaselway/weaselway";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.nixos-wsl.follows = "nixos-wsl";
  };
}
