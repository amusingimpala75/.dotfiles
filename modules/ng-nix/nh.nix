{
  flake.wrappers.nh =
    {
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.nh ];
      flake = "$HOME/.dotfiles";
    };
}
