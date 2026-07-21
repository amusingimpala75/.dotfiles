_: {
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          actionlint
          fennel-ls
          just
          luaPackages.fennel
          nixfmt
          nixfmt-tree
          pre-commit
          sops
        ];
      };
    };
}
