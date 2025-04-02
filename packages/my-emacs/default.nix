{
  # nixpkgs lib
  stdenv,

  # pkgs
  clang,    # Darwin uses clang,
  libclang, # nixos uses libclang
  cargo,
  emacs30,
  emacsPackages,
  ghostscript,
  jdt-language-server,
  lua-language-server,
  python3,
  rust-analyzer,
  rustc,
  rustfmt,
  texlive,
  typescript-language-server,
  vlc,

  # builders
  emacsWithPackagesFromUsePackage,
  writeText,

  # configuration options
  font-size ? 16,
  font-family-fixed ? "Iosevka",
  font-family-variable ? "Iosevka Etoile",
  opacity ? 1.0,
  theme-package ? emacsPackages.gruvbox-theme,
  theme-file-name ? "gruvbox-theme",
  theme-name ? "gruvbox-dark-hard",
  ...
}:
let
  pylsp = python3.withPackages (p: (with p; [
    python-lsp-server
    pylsp-rope
    pylsp-mypy
    python-lsp-ruff
  ]));
  clangd = if stdenv.isDarwin then clang else libclang;
in
emacsWithPackagesFromUsePackage {
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

        (defvar my/vlc "${vlc}/bin/vlc")

        (defvar my/texlive-bin "${texlive.combined.scheme-full}/bin")
        (defvar my/ghostscript-bin "${ghostscript}/bin")

        (defvar my/rustfmt-bin "${rustfmt}/bin")
        (defvar my/cargo-bin "${cargo}/bin")
        (defvar my/rustc-bin "${rustc}/bin")

        (defvar my/jdtls-bin "${jdt-language-server}/bin")
        (defvar my/lua-language-server-bin "${lua-language-server}/bin")
        (defvar my/rust-analyzer-bin "${rust-analyzer}/bin")
        (defvar my/clang-bin "${clangd}/bin")
        (defvar my/python-lsp-server-bin "${pylsp}/bin")
        (defvar my/typescript-language-server-bin "${typescript-language-server}/bin")

        (defvar my/snippets-dir "${./snippets}")

        (require '${theme-file-name})
        (load-theme '${theme-name} t)

        (provide 'nix-settings)
      '';
      packageRequires = [ theme-package ];
    })
  ];
}
