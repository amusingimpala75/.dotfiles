{
  aerospace,
  scriptWrapper,

  lib,
  ...
}:
scriptWrapper {
  path = ./float_and.sh;
  extraMeta = {
    platforms = lib.platforms.darwin;
  };
  deps = [ aerospace ];
}
