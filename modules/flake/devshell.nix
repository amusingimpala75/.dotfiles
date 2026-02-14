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
          bash-language-server
          fennel-ls
          luaPackages.fennel
          nixd
          nixfmt-tree
          sops
        ];
      };
    };
}
