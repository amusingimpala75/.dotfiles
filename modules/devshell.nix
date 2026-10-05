_: {
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          actionlint
          fennel-ls
          just
          luaPackages.fennel
          nixfmt-rs
          self'.formatter
          pre-commit
          sops
        ];
      };
    };
}
