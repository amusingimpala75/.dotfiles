{
  ffmpeg,
  scriptWrapper,
  ...
}:
scriptWrapper {
  path = ./play-audio.sh;
  deps = [ ffmpeg ];
  extraMeta = {
    description = "play an audio track (possibly looping) with ffmpeg";
  };
}
