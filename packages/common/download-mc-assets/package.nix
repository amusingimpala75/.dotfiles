{
  curl,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "download-mc-assets";
  text = builtins.readFile ./download-mc-assets.sh;
  runtimeInputs = [
    curl
  ];
  meta.description = "Download Minecraft music assets";
}
