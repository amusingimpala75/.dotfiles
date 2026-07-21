{
  ffmpeg,
  jaq,

  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "play-audio";
  text = builtins.readFile ./play-audio.sh;
  runtimeInputs = [
    ffmpeg
    jaq
  ];
  meta = {
    description = "play an audio track (possibly looping) with ffmpeg";
    platforms = lib.platforms.all;
  };
}
