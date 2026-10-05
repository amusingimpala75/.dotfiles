{
  # pkgs
  aspellWithDicts,
  emacs,
  librsvg,
  mpv,
  pandoc,
  unzip,
  vimPlugins,
  zip,

  # Language servers
  bash-language-server,
  biome,
  clang-tools,
  copilot-language-server,
  gopls,
  harper,
  jdt-language-server,
  nixd,
  rassumfrassum,
  rust-analyzer,
  typescript-language-server,
  zls,
  zuban,

  # builders
  emacsWithPackagesFromUsePackage,
  lib,
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
symlinkJoin {
  pname = "custom-emacs";
  inherit (emacs) version;
  paths = [
    (emacsWithPackagesFromUsePackage {
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
    })

    # Dictionary support
    (aspellWithDicts (dicts: [ dicts.en ]))
    # emms
    (mpv.override { youtubeSupport = false; })
    # ox-pandoc
    pandoc
    # Compression
    unzip
    zip
    # eplot
    librsvg
    # LSPs
    rassumfrassum
    clang-tools # clangd for C
    jdt-language-server # jdtls for Java
    biome # these two for
    typescript-language-server # TypeScript
    zuban # for python
    rust-analyzer # for Rust
    zls # for Zig
    nixd # for Nix
    bash-language-server # for Bash
    gopls # for Go
    harper # for grammar
    # AI tab complete
    copilot-language-server
  ];

  meta = {
    description = "My custom emacs config";
    mainProgram = "emacs";
    platforms = lib.platforms.all;
  };
}
