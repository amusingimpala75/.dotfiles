{
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nixd
          luaPackages.fennel
          fennel-ls
          nixfmt-tree
          sops
        ];
      };
    };
}
