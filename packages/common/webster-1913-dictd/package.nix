{
  bison,
  dict,
  fetchurl,
  flex,
  lib,
  stdenv,
  ...
}:

let
  version = "1.4-0.47pd-2";
in
stdenv.mkDerivation {
  # Keep the derivation name matching the DICT database basename; the local
  # dictd module uses package.name as the database name.
  name = "web1913";
  inherit version;

  src = fetchurl {
    url = "https://snapshot.debian.org/file/edbb34c19958b0fc2b15fce54cd0efe9b59010ea";
    name = "dict-web1913_1.4-0.47pd.orig.tar.gz";
    hash = "sha256-Afr7LAIMMsd1GpqxqSjYeqeFRDHdhe84S+VT/A2PkAM=";
  };

  nativeBuildInputs = [
    bison
    dict
    flex
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-int -Wno-error=implicit-function-declaration";

  postPatch = ''
    # Old libmaa relies on GCC accepting __FUNCTION__ in string-literal
    # concatenation. Clang rejects that, so rewrite the logging format strings.
    substituteInPlace libmaa/parse.c \
      --replace-fail '__FUNCTION__ ": Using KHEPERA_CPP from %s\n"' '"%s: Using KHEPERA_CPP from %s\n", __FUNCTION__' \
      --replace-fail '__FUNCTION__ ": Using GNU cpp from %s\n"' '"%s: Using GNU cpp from %s\n", __FUNCTION__' \
      --replace-fail '__FUNCTION__ ": Using system cpp from %s\n"' '"%s: Using system cpp from %s\n", __FUNCTION__' \
      --replace-fail '__FUNCTION__ ": %s\n"' '"%s: %s\n", __FUNCTION__'
  '';

  configureFlags = [
    "--with-datapath=./web1913_0.47-pd"
    "--with-tmppath=."
  ];

  buildPhase = ''
    runHook preBuild

    make
    make db DICTZIP=cat

    # dictzip records the input file mtime. Normalize it for reproducible output.
    touch -d "@$SOURCE_DATE_EPOCH" web1913.dict web1913.index
    dictzip -v web1913.dict

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/dictd
    cp web1913.dict.dz web1913.index $out/share/dictd/
    echo en_US.UTF-8 > $out/share/dictd/locale

    runHook postInstall
  '';

  passthru = {
    dbName = "web1913";
  };

  meta = {
    description = "Webster's Revised Unabridged Dictionary (1913) for dictd";
    homepage = "https://sources.debian.org/src/dict-web1913/1.4-0.47pd-2/";
    license = [
      lib.licenses.publicDomain
      lib.licenses.gpl1Plus
    ];
    maintainers = [ ];
  };
}
