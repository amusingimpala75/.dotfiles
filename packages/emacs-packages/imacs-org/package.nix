{
  org-modern,
  org-modern-indent,
  ox-pandoc,
  ox-typst,
  engrave-faces,
  org-appear,
  org-present,
  melpaBuild,
  ...
}:
melpaBuild {
  pname = "imacs-org";
  version = "0.1";
  src = ./.;
  packageRequires = [
    org-modern
    org-modern-indent
    ox-pandoc
    ox-typst
    engrave-faces
    org-appear
    org-present
  ];
}
