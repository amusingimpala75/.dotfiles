{
  lib,
  config,
  ...
}:
{
  options.my.starship.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
  };

  config.programs.starship = lib.mkIf config.my.starship.enable {
    enable = true;
  };
}
