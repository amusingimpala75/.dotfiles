{
  # pkgs
  aspellWithDicts,
  emacs,
  harper,
  mpv,
  pandoc,
  rassumfrassum,
  unzip,
  vimPlugins,
  zip,

  # Fonts
  maple-mono,
  liberation_ttf,
  noto-fonts-cjk-sans,

  # builders
  emacsWithPackagesFromUsePackage,
  fetchFromGitHub,
  lib,
  symlinkJoin,
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
      ];
      override = _: prev: {
        # Fix the lexical cookie
        nord-theme = prev.nord-theme.overrideAttrs {
          src = fetchFromGitHub {
            owner = "KevinBoyette";
            repo = "nord-emacs";
            rev = "3724815f068ed000fcf922c1aa6aca46c77ae633";
            hash = "sha256-665DFiKiDv3zVg41kkv85wihkGWOoD3YJZUpCbau6+U=";
          };
        };
      };
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
    # LSP multiplexer
    rassumfrassum
    # Grammar LSP
    harper

    # Fonts
    maple-mono.NF-CN-unhinted
    liberation_ttf
    noto-fonts-cjk-sans
  ];

  meta = {
    description = "My custom emacs config";
    mainProgram = "emacs";
    platforms = lib.platforms.all;
  };
}
