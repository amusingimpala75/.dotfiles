{
  ghostel,
  toggleterm,
  xterm-color,

  melpaBuild,
  ...
}:
melpaBuild {
  pname = "imacs-shell";
  version = "0.1";
  src = ./.;
  packageRequires = [
    ghostel
    toggleterm
    xterm-color
  ];
}
