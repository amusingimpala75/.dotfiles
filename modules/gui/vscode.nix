{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.vscode = pkgs.vscode-with-extensions.override {
        vscode = pkgs.vscodium;
        vscodeExtensions = with pkgs.vscode-extensions; [
          arcticicestudio.nord-visual-studio-code
          bbenoist.nix
          mkhl.direnv
        ];
      };
    };

  flake.modules.homeManager.vscode = _: {

  };
}
