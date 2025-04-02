{
  emacsPackages,
  writeText,
  ...
}:
theme: emacsPackages.trivialBuild {
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

    (setq base16-theme-256-color-source 'colors)

    (provide 'my-base16-theme)
  '';
  packageRequires = [ emacsPackages.base16-theme ];
}
