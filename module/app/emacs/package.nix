pkgs: userSettings:
let
  vlc-pkg = if pkgs.stdenv.isDarwin then pkgs.vlc-bin else pkgs.vlc;
  make-grammar = package: filename: package.overrideAttrs (old: {
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      mv parser "$out/${filename}" # only change is here
      if [[ -d queries ]]; then
      cp -r queries $out
      fi
      runHook postInstall
    '';
  });
  pylsp = pkgs.python3.withPackages (p: (with p; [
    python-lsp-server
    pylsp-rope
    pylsp-mypy
    python-lsp-ruff
  ]));
  clangd = if pkgs.stdenv.isDarwin then pkgs.clang else pkgs.libclang;
in
pkgs.emacsWithPackagesFromUsePackage {
  package = pkgs.emacs30;
  alwaysTangle = true;
  defaultInitFile = true;
  config = ./config.org;
  extraEmacsPackages = epkgs: [
    (epkgs.trivialBuild {
      pname = "my-base16-theme";
      version = "0.1.0";
      src = pkgs.writeText "my-base16-theme.el" (with userSettings.theme; ''
        (require 'base16-theme)

        (defvar my-base16-theme-colors
        '(:base00 "#${base00}"
        :base01 "#${base01}"
        :base02 "#${base02}"
        :base03 "#${base03}"
        :base04 "#${base04}"
        :base05 "#${base05}"
        :base06 "#${base06}"
        :base07 "#${base07}"
        :base08 "#${base08}"
        :base09 "#${base09}"
        :base0A "#${base0A}"
        :base0B "#${base0B}"
        :base0C "#${base0C}"
        :base0D "#${base0D}"
        :base0E "#${base0E}"
        :base0F "#${base0F}"))

        (deftheme my-base16)
        (base16-theme-define 'my-base16 my-base16-theme-colors)
        (provide-theme 'my-base16)

        (add-to-list 'custom-theme-load-path (file-name-directory (file-truename load-file-name)))

        (provide 'my-base16-theme)
      '');
      packageRequires = [ epkgs.base16-theme ];
    })
    (epkgs.trivialBuild {
      pname = "nix-settings";
      version = "0.1.0";
      src = pkgs.writeText "nix-settings.el" (with userSettings; ''
        (defvar my/font-family-fixed-pitch "${font.family.fixed-pitch}")
        (defvar my/font-family-variable-pitch "${font.family.variable-pitch}")
        (defvar my/font-size ${builtins.toString font.size})

        (defvar my/opacity (truncate ${builtins.toString (opacity * 100)}))

        (defvar my/vlc "${vlc-pkg}/bin/vlc")

        (defvar my/texlive-bin "${pkgs.texlive.combined.scheme-full}/bin")
        (defvar my/ghostscript-bin "${pkgs.ghostscript}/bin")

        (defvar my/rustfmt-bin "${pkgs.rustfmt}/bin")
        (defvar my/cargo-bin "${pkgs.cargo}/bin")
        (defvar my/rustc-bin "${pkgs.rustc}/bin")

        (defvar my/jdtls-bin "${pkgs.jdt-language-server}/bin")
        (defvar my/lua-language-server-bin "${pkgs.lua-language-server}/bin")
        (defvar my/zls-bin "${pkgs.zls}/bin")
        (defvar my/rust-analyzer-bin "${pkgs.rust-analyzer}/bin")
        (defvar my/clang-bin "${clangd}/bin")
        (defvar my/python-lsp-server-bin "${pylsp}/bin")
        (defvar my/typescript-language-server-bin "${pkgs.typescript-language-server}/bin")

        (defvar my/treesitter-rust "${make-grammar pkgs.tree-sitter-grammars.tree-sitter-rust "libtree-sitter-rust.so"}")
        (defvar my/treesitter-c "${make-grammar pkgs.tree-sitter-grammars.tree-sitter-c "libtree-sitter-c.so"}")
        (defvar my/treesitter-cpp "${make-grammar pkgs.tree-sitter-grammars.tree-sitter-cpp "libtree-sitter-cpp.so"}")
        (defvar my/treesitter-python "${make-grammar pkgs.tree-sitter-grammars.tree-sitter-python "libtree-sitter-python.so"}")
        (defvar my/treesitter-javascript "${make-grammar pkgs.tree-sitter-grammars.tree-sitter-javascript "libtree-sitter-javascript.so"}")

        (provide 'nix-settings)
      '');
    })
  ];
}
