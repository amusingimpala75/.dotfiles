{
  inputs,
  ...
}:
{
  flake.modules.homeManager.sops =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        age.keyFile =
          if pkgs.stdenv.isDarwin then
            "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt"
          else
            "${config.home.homeDirectory}/.config/sops/age/keyis.txt";
        defaultSopsFile = ../../secrets/secrets.yaml;
        secrets."emacs-feeds.el" = {
          format = "binary";
          sopsFile = ../../secrets/emacs-feeds.el;
          path = "%r/emacs-feeds.el";
        };
        secrets."emacs-radio-channels.el" = {
          format = "binary";
          sopsFile = ../../secrets/emacs-radio-channels.el;
          path = "%r/emacs-radio-channels.el";
        };
      };
    };
}
