{
  # pkgs
  aspellWithDicts,
  emacs31,
  mpv,
  pandoc,
  unzip,
  vimPlugins,
  zip,

  bash-language-server,
  biome,
  clang-tools,
  gopls,
  jdt-language-server,
  nixd,
  rassumfrassum,
  rust-analyzer,
  ty,
  typescript-language-server,
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
  emacs = emacs31;
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
  };

  deps = symlinkJoin {
    name = "emacs30-path-additions";
    paths = [
      # Dictionary support
      (aspellWithDicts (dicts: [ dicts.en ]))
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
      clang-tools # clangd for C
      jdt-language-server # jdtls for Java
      biome # these two for
      typescript-language-server # TypeScript
      zuban # these two
      ty # for Python
      rust-analyzer # for Rust
      zls # for Zig
      nixd # for Nix
      bash-language-server # for Bash
      gopls # for Go
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
