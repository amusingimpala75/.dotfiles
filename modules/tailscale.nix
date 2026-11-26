{
  flake.modules = {
    nixos.tailscale =
      {
        config,
        ...
      }:
      {
        services.tailscale.enable = true;

        networking.firewall = {
          checkReversePath = "loose";
          trustedInterfaces = [ "tailscale0" ];
          allowedUDPPorts = [ config.services.tailscale.port ];
        };
      };

    darwin.tailscale = {
      services.tailscale.enable = true;
    };
  };
}
