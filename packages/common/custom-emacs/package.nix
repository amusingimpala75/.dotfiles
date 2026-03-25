{
  # pkgs
  aspellWithDicts,
  bash-language-server,
  biome,
  clang-tools,
  emacs,
  ghostscript,
  jdt-language-server,
  mathjax-node-cli,
  metals,
  mpv,
  nixd,
  pandoc,
  python3,
  R,
  rassumfrassum,
  rust-analyzer,
  stable ? null,
  texlive,
  ty,
  typescript-language-server,
  unzip,
  vimPlugins,
  zip,
  zls,
  zuban,

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
  theme-package ? epkgs: epkgs.gruvbox-theme,
  theme-file-name ? "gruvbox-theme",
  theme-name ? "gruvbox-dark-hard",
  ...
}:
let
  pkg = emacsWithPackagesFromUsePackage {
    package = emacs;
    alwaysTangle = true;
    defaultInitFile = true;
    config = ./init.el;
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
          ;;; -*- lexical-binding: t; -*-
          (defvar my/font-family-fixed-pitch "${font-family-fixed}")
          (defvar my/font-family-variable-pitch "${font-family-variable}")
          (defvar my/font-size ${toString font-size})

          (defvar my/opacity (truncate ${toString (opacity * 100)}))

          (require '${theme-file-name})
          (defvar my/theme '${theme-name})

          (provide 'nix-settings)
        '';
        packageRequires = [ (theme-package epkgs) ];
      })
    ];
    override = epkgs: {
      org = epkgs.org-karthik;
    };
  };

  texlive-base = if stable != null then stable.texlive else texlive;

  texlive-package = texlive-base.combine {
    inherit (texlive-base)
      scheme-medium
      mylatexformat
      preview # for latex preview
      capt-of # for tikz automata
      fvextra
      upquote
      tcolorbox
      wrapfig
      pdfcol # for latex precomp
      ;
  };

  deps = symlinkJoin {
    name = "emacs30-path-additions";
    paths = [
      # Dictionary support
      (aspellWithDicts (dicts: [ dicts.en ]))
      # Org mode stuff
      ghostscript
      mathjax-node-cli
      texlive-package
      # Mpv: no youtube b/c compiles from source then
      (mpv.override {
        youtubeSupport = false;
      })
      # needed by ox-pandoc
      pandoc
      # Compression
      unzip
      zip
      # LSPs
      rassumfrassum
      clang-tools                # clangd for C
      jdt-language-server        # jdtls for Java
      biome                      # these two for
      typescript-language-server # TypeScript
      zuban                      # these two
      ty                         # for Python
      rust-analyzer              # for Rust
      metals                     # for Scala
      zls                        # for Zig
      nixd                       # for Nix
      bash-language-server       # for Bash

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
  inherit (emacs) version;
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
