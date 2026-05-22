{
  fetchFromGitHub,
  melpaBuild,
  magit,
  ...
}:
melpaBuild {
  pname = "majutsu";
  version = "0-unstable-2026-05-17";
  src = fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "aebd5acdecd1fa6de249dabd274b963cd73d3bfc";
    hash = "sha256-syZEyoP0p1B/Mw5X98Wb9yxbVRygtxU+WzSYn2QivNQ=";
  };
  packageRequires = [
    magit
  ];
}
