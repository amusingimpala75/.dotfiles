_: {
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          fennel-ls
          just
          luaPackages.fennel
          nixfmt
          nixfmt-tree
          sops
        ];
      };
    };
}
