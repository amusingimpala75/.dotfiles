{
  fetchFromGitHub,
  melpaBuild,
  ...
}:
melpaBuild {
  pname = "org-modern-indent";
  version = "0-unstable-2025-04-12";
  src = fetchFromGitHub {
    owner = "jdtsmith";
    repo = "org-modern-indent";
    rev = "9973bd3b91e4733a3edd1fca232208c837c05473";
    hash = "sha256-st3338Jk9kZ5BLEPRJZhjqdncMpLoWNwp60ZwKEObyU=";
  };
}
