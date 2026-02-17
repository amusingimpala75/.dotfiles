{
  ffmpeg,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "play-audio";
  text = builtins.readFile ./play-audio.sh;
  runtimeInputs = [ ffmpeg ];
  meta.description = "play an audio track (possibly looping) with ffmpeg";
}
