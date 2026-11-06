{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = [
          config.treefmt.build.devShell
        ];

        packages = with pkgs; [
          bash-language-server
          fennel-ls
          just
          luaPackages.fennel
          nixd
          pre-commit
          sops
        ];
      };
    };
}
