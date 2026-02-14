{
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "ghostty_and";
  text = ''open -na Ghostty --args --command="$1" "$2"'';
}
