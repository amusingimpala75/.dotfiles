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
  meta = {
    description = "Float the current window and execute the following command";
    platforms = lib.platforms.darwin;
  };
  runtimeInputs = [ aerospace ];
}

