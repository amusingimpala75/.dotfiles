{
  self,
  ...
}:
{
  flake.templates = builtins.mapAttrs (key: _: {
    # curse detsys nix and its stupid checks
    path = /. + builtins.unsafeDiscardStringContext "${self}/templates/${key}";
    inherit (import "${self}/templates/${key}/flake.nix") description;
  }) (builtins.readDir "${self}/templates");
}
