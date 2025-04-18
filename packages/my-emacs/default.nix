{
  # pkgs
  emacs30,
  emacsPackagesFor,
  ghostscript,
  nixd,
  nixfmt-rfc-style,
  texlive,
  vlc,

  # builders
  emacsWithPackagesFromUsePackage,
  makeWrapper,
  symlinkJoin,
  writeText,

  # configuration options
  font-size ? 16,
  font-family-fixed ? "Iosevka",
  font-family-variable ? "Iosevka Etoile",
  opacity ? 1.0,
  theme-package ? (emacsPackagesFor emacs30).gruvbox-theme,
  theme-file-name ? "gruvbox-theme",
  theme-name ? "gruvbox-dark-hard",
  ...
}:
let
  pkg = emacsWithPackagesFromUsePackage {
    package = emacs30;
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
          (load-theme '${theme-name} t)

          (provide 'nix-settings)
        '';
        packageRequires = [ theme-package ];
      })
      (epkgs.trivialBuild {
        pname = "normie-mode";
        version = "0.1.0";
        src = ./normie-mode.el;
      })
    ];
  };
  deps = symlinkJoin {
    name = "emacs30-path-additions";
    paths = [
      nixd
      nixfmt-rfc-style
      texlive.combined.scheme-full
      ghostscript
      vlc
    ];
  };
in
symlinkJoin {
  inherit (pkg) name;
  paths = [ pkg ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/emacs --prefix PATH : ${deps}/bin
    wrapProgram $out/bin/emacsclient --prefix PATH: ${deps}/bin
  '';
}
