{
  flake.wrappers.bottom =
    {
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.bottom ];
      settings.flags.basic = true;
    };
}
