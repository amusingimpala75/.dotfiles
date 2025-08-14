{
  # pkgs
  emacs,
  emacsPackagesFor,
  ghostscript,
  mpv,
  stable ? null,
  texlive,
  yt-dlp,

  # builders
  emacsWithPackagesFromUsePackage,
  fetchFromGitHub,
  makeWrapper,
  symlinkJoin,
  writeText,

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
          (load-theme '${theme-name} t)

          (provide 'nix-settings)
        '';
        packageRequires = [ theme-package ];
      })
      (epkgs.trivialBuild {
        pname = "zone-matrix";
        version = "git+2023-12-21";
        src = fetchFromGitHub {
          owner = "twitchy-ears";
          repo = "zone-matrix";
          rev = "508e2fa6f1d9b69752c1629f76349bdd102f40d1";
          hash = "sha256-uQQviKTvZfWcdovfxy/jF60onFEJYcp98nDrtDt2CGA=";
        };
      })
      (epkgs.trivialBuild {
        pname = "combobulate";
        version = "git+2025-6-20";
        src = fetchFromGitHub {
          owner = "mickeynp";
          repo = "combobulate";
          rev = "17c71802eed2df1a6b25199784806da6763fb90c";
          hash = "sha256-m+06WLfHkdlMkLzP+fah3YN3rHG0H8t/iWEDSrct25E=";
        };
      })
      (epkgs.trivialBuild {
        pname = "nnnrss";
        version = "git+2025-3-9";
        src = fetchFromGitHub {
          owner = "jjbarr";
          repo = "nnnrss";
          rev = "941f89277fabd44dd03eb654e183553c86ba35c8";
          hash = "sha256-rm5bquIsdY8Nj7l8B2nxu7tpNszNlN1zwjBA09yvpCs=";
        };
      })
    ];
  };

  texlive-package =
    if stable != null then stable.texlive.combined.scheme-full else texlive.combined.scheme-full;

  deps = symlinkJoin {
    name = "emacs30-path-additions";
    paths = [
      texlive-package
      ghostscript
      mpv
      yt-dlp
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
