{
  fetchFromGitHub,
  melpaBuild,
  ...
}:
let
  version = "0.4.3";
in
melpaBuild {
  pname = "clatter";
  inherit version;
  src = fetchFromGitHub {
    owner = "parenworks";
    repo = "clatter.el";
    tag = "v${version}";
    hash = "sha256-85CoaJS6nUyoWrwCH45PZUsYpa1mIH0QhB1C7OJnXyU=";
  };
}
