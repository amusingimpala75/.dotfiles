{
  scriptWrapper,
  ...
}:
# Technically this is impure since it will call out to the
# application Ghostty which is not being managed by Nix.
# oh well ¯\_("/)_/¯
scriptWrapper "ghostty_and" []
