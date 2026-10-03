{
  description = "flake-parts flake with devshell for org-latex exports";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = [
              (pkgs.texlive-base.combine {
                inherit (pkgs.texlive-base)
                  scheme-medium
                  mylatexformat
                  preview
                  capf-of
                  fvextra
                  upquote
                  tcolorbox
                  wrapfig
                  pdfcol
                  enumitem
                  ;
              })
            ];
          };
        };
    };
}
