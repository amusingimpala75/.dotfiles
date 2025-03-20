{
  # nixpkgs lib
  lib,
  stdenv,

  # pkgs
  clang,    # Darwin uses clang,
  libclang, # nixos uses libclang
  cargo,
  emacs30,
  ghostscript,
  jdt-language-server,
  lua-language-server,
  python3,
  rust-analyzer,
  rustc,
  rustfmt,
  texlive,
  typescript-language-server,
  vlc, # TODO change pkgs.vlc-bin to replace vlc

  # builders
  emacsWithPackagesFromUsePackage,
  writeText,

  # configuration options
  font-size ? 16,
  font-family-fixed ? "Iosevka",
  font-family-variable ? "Iosevka Etoile",
  opacity ? 1.0,
  theme ? import ../../modules/theme/generated/gruvbox-dark-hard,
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
      pname = "my-base16-theme";
      version = "0.1.0";
      src = writeText "my-base16-theme.el" ''
        (require 'base16-theme)

        (defvar my-base16-theme-colors
        '(:base00 "#${theme.base00}"
        :base01 "#${theme.base01}"
        :base02 "#${theme.base02}"
        :base03 "#${theme.base03}"
        :base04 "#${theme.base04}"
        :base05 "#${theme.base05}"
        :base06 "#${theme.base06}"
        :base07 "#${theme.base07}"
        :base08 "#${theme.base08}"
        :base09 "#${theme.base09}"
        :base0A "#${theme.base0A}"
        :base0B "#${theme.base0B}"
        :base0C "#${theme.base0C}"
        :base0D "#${theme.base0D}"
        :base0E "#${theme.base0E}"
        :base0F "#${theme.base0F}"))

        (deftheme my-base16)
        (base16-theme-define 'my-base16 my-base16-theme-colors)
        (provide-theme 'my-base16)

        (add-to-list 'custom-theme-load-path (file-name-directory (file-truename load-file-name)))

        (provide 'my-base16-theme)
      '';
      packageRequires = [ epkgs.base16-theme ];
    })
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

        (provide 'nix-settings)
      '';
    })
  ];
}
