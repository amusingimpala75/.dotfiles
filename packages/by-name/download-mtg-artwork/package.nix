{
  curl,
  file,
  gnugrep,

  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "download-mtg-artwork";
  text = builtins.readFile ./download.sh;
  runtimeInputs = [
    curl
    file
    gnugrep
  ];
  meta = {
    description = "download a series of artwork from a MtG set";
    platforms = lib.platforms.all;
  };
}
