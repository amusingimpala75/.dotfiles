{
  # pkgs
  bleeding ? null,
  emacs,
  emacsPackagesFor,
  ghostscript,
  mathjax-node-cli,
  mpv,
  mupdf-headless,
  pandoc,
  python3,
  R,
  stable ? null,
  texlive,
  unzip,
  yt-dlp,
  zip,

  # builders
  emacsWithPackagesFromUsePackage,
  fetchFromGitHub,
  fetchFromGitea,
  gcc,
  gnumake,
  makeWrapper,
  pkg-config,
  symlinkJoin,
  writeText,

  lib,
  stdenv,

  # configuration options
  font-size ? 16,
  font-family-fixed ? "Iosevka",
  font-family-variable ? "Iosevka Etoile",
  opacity ? 1.0,
  theme-package ? (emacsPackagesFor emacs).gruvbox-theme,
  theme-file-name ? "gruvbox-theme",
  theme-name ? "gruvbox-dark-hard",
  ...
}:
let
  getPackage =
    path:
    (import path) {
      inherit
        emacs
        emacsPackagesFor
        fetchFromGitHub
        fetchFromGitea
        gcc
        gnumake
        lib
        mupdf-headless
        pkg-config
        stdenv
        ;
    };
  pkg = emacsWithPackagesFromUsePackage {
    package = emacs;
    alwaysTangle = true;
    defaultInitFile = true;
    config = ./config.org;
    extraEmacsPackages = epkgs: [
      epkgs.treesit-grammars.with-all-grammars
      (epkgs.trivialBuild {
        pname = "nix-settings";
        version = "0.1.0";
        src = writeText "nix-settings.el" ''
          (defvar my/font-family-fixed-pitch "${font-family-fixed}")
          (defvar my/font-family-variable-pitch "${font-family-variable}")
          (defvar my/font-size ${builtins.toString font-size})

          (defvar my/opacity (truncate ${builtins.toString (opacity * 100)}))

          (require '${theme-file-name})
          (defvar my/theme '${theme-name})

          (provide 'nix-settings)
        '';
        packageRequires = [ theme-package ];
      })
      (getPackage ./zone-matrix.nix)
      (getPackage ./combobulate.nix)
      (getPackage ./nnnrss.nix)
      (getPackage ./org-modern-indent.nix)
      (getPackage ./toggleterm.nix)
      (getPackage ./reader.nix)
      (getPackage ./page-view.nix)
    ];
  };

  texlive-package =
    if stable != null then stable.texlive.combined.scheme-full else texlive.combined.scheme-full;

  yt-dlp-package = if bleeding != null then bleeding.yt-dlp else yt-dlp;
  # this is only necessary since we're already pulling yt-dlp as bleeding;
  # there is no reason to then pull mpv as unstable as
  # that then pulls in yt-dlp as stable as well, extraneous extra packages
  mpv-package = if bleeding != null then bleeding.mpv else mpv;

  deps = symlinkJoin {
    name = "emacs30-path-additions";
    paths = [
      texlive-package
      ghostscript
      mathjax-node-cli
      mpv-package
      pandoc
      unzip
      yt-dlp-package
      zip

      # There has to be a way so that ob-jupyter
      # doesn't just throw an error if jupyter isn't
      # present when we don't actually need jupyter
      # and we're just trying to export the file
      (python3.withPackages (pp: [ pp.jupyter]))
      R
    ];
  };
in
symlinkJoin {
  pname = "emacs-with-packages";
  version = emacs.version;
  paths = [ pkg ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/emacs --prefix PATH : ${deps}/bin
    wrapProgram $out/bin/emacsclient --prefix PATH: ${deps}/bin
  '';

  meta.description = "My custom emacs config";
}
