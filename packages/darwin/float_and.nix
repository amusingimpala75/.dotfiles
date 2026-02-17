{
  aerospace,
  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "float_and";
  text = ''
  aerospace floating
  "$@"
  '';
  meta.platforms = lib.platforms.darwin;
  runtimeInputs = [ aerospace ];
}

