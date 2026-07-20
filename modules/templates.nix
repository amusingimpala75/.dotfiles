{
  self,
  ...
}:
{
  flake.templates = builtins.mapAttrs (key: _: {
    path = "${self}/templates/${key}";
    inherit (import "${self}/templates/${key}/flake.nix") description;
  }) (builtins.readDir "${self}/templates");
}
