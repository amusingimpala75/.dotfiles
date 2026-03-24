{
  cape,
  consult,
  corfu,
  embark,
  embark-consult,
  marginalia,
  orderless,
  wgrep,
  yasnippet,
  yasnippet-capf,
  yasnippet-snippets,

  melpaBuild,
  ...
}:
melpaBuild {
  pname = "imacs-completion";
  version = "0.1";
  src = ./.;
  packageRequires = [
    cape
    consult
    corfu
    embark
    embark-consult
    marginalia
    orderless
    wgrep
    yasnippet
    yasnippet-capf
    yasnippet-snippets
  ];
}
