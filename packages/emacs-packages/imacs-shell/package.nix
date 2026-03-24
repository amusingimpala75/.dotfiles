{
  eat,
  eshell-vterm,
  toggleterm,
  vterm,
  xterm-color,

  melpaBuild,
  ...
}:
melpaBuild {
  pname = "imacs-shell";
  version = "0.1";
  src = ./.;
  packageRequires = [
    eat
    vterm
    toggleterm
    eshell-vterm
    xterm-color
  ];
}
