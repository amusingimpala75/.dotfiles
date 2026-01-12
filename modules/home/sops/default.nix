{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  options.my.sops.age-key = lib.mkOption {
    description = "path to sops age key";
    type = lib.types.str;
    default =
      if pkgs.stdenv.isDarwin then
        "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt"
      else
        "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  config.sops = {
    age.keyFile = config.my.sops.age-key;
    defaultSopsFile = ../../../secrets/secrets.yaml;
    secrets."emacs-feeds.el" = {
      format = "binary";
      sopsFile = ../../../secrets/emacs-feeds.el;
      path = "%r/emacs-feeds.el";
    };
    secrets."emacs-radio-channels.el" = {
      format = "binary";
      sopsFile = ../../../secrets/emacs-radio-channels.el;
      path = "%r/emacs-radio-channels.el";
    };
  };
}
