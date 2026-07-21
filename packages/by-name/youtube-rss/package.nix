{
  curl,
  htmlq,

  lib,
  writeShellApplication,
}:
writeShellApplication {
  name = "youtube-rss";
  text = builtins.readFile ./youtube-rss.sh;
  meta.platforms = lib.platforms.all;
  runtimeInputs = [
    curl
    htmlq
  ];
}
