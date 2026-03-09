_: {
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          bash-language-server
          fennel-ls
          just
          luaPackages.fennel
          nixd
          nixfmt-tree
          sops
        ];
      };
    };
}
