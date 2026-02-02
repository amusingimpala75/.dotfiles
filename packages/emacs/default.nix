{
  # pkgs
  aspellWithDicts,
  bleeding ? null,
  emacs,
  emacsPackagesFor,
  ghostscript,
  mathjax-node-cli,
  mpv,
  pandoc,
  python3,
  R,
  scala-cli,
  stable ? null,
  texlive,
  unzip,
  vimPlugins,
  yt-dlp,
  zip,

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
      (epkgs.treesit-grammars.with-grammars (
        p:
        # This line is the same as with-all-grammars
        (builtins.attrValues p)
        # This line allows us to copy any of the nvim parsers
        # that (for some reason) aren't exposed normally
        ++ (map (s: vimPlugins.nvim-treesitter-parsers."${s}".origGrammar) [
          "doxygen"
        ])
      ))
      (epkgs.trivialBuild {
        pname = "nix-settings";
        version = "0.1.0";
        src = writeText "nix-settings.el" ''
          (defvar my/font-family-fixed-pitch "${font-family-fixed}")
          (defvar my/font-family-variable-pitch "${font-family-variable}")
          (defvar my/font-size ${toString font-size})

          (defvar my/opacity (truncate ${toString (opacity * 100)}))

          (require '${theme-file-name})
          (defvar my/theme '${theme-name})

          (provide 'nix-settings)
        '';
        packageRequires = [ theme-package ];
      })
      epkgs.nnnrss
      epkgs.org-modern-indent
      epkgs.scala-cli-repl
      epkgs.toggleterm
      epkgs.reader
      epkgs.page-view
    ];
    override = epkgs: {
      org = epkgs.org-karthik;
    };
  };

  texlive-base = if stable != null then stable.texlive else texlive;

  texlive-package = texlive-base.combine {
    inherit (texlive-base)
      scheme-medium
      mylatexformat preview    # for latex preview
      capt-of                  # for tikz automata
      ;
  };

  yt-dlp-package = if bleeding != null then bleeding.yt-dlp else yt-dlp;
  # this is only necessary since we're already pulling yt-dlp as bleeding;
  # there is no reason to then pull mpv as unstable as
  # that then pulls in yt-dlp as stable as well, extraneous extra packages
  mpv-package = if bleeding != null then bleeding.mpv else mpv;

  deps = symlinkJoin {
    name = "emacs30-path-additions";
    paths = [
      (aspellWithDicts (dicts: [ dicts.en ]))
      ghostscript
      mathjax-node-cli
      mpv-package
      pandoc
      scala-cli
      texlive-package
      unzip
      yt-dlp-package
      zip

      # There has to be a way so that ob-jupyter
      # doesn't just throw an error if jupyter isn't
      # present when we don't actually need jupyter
      # and we're just trying to export the file
      (python3.withPackages (pp: [ pp.jupyter ]))
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

  meta = {
    description = "My custom emacs config";
    mainProgram = "emacs";
  };
}
