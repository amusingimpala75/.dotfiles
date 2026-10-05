{
  # pkgs
  aspellWithDicts,
  emacs,
  librsvg,
  mpv,
  pandoc,
  unzip,
  vimPlugins,
  youtube-rss,
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

  # Fonts
  maple-mono,
  liberation_ttf,
  noto-fonts-cjk-sans,

  # builders
  emacsWithPackagesFromUsePackage,
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
    # newsticker
    youtube-rss
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
