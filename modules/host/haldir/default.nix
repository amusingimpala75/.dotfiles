{
  self,
  ...
}:
let
  baseDomain = "amusingimpala.com";
  headscaleSubdomain = "headscale";
  mdnsSubdomain = "tail";
  ipv6Addr = "2001:19f0:8000:1df8:5400:07ff:fe19:5588";
in
{
  # Because of limited disk space, you need to make a Vultr vm
  # from the nixos iso to avoid kexec, and run:
  # nix run nixos-anywhere -- \
  #   --flake .#haldir \
  #   --target-host nixos@<ip> \
  #   --no-disko-deps.
  # subsequent changes can be made with:
  # nh os switch .#haldir \
  #   --target-host nixos@<ip> \
  #   --elevation-strategy passwordless
  flake.nixosConfigurations =
    let
      domain = "${headscaleSubdomain}.${baseDomain}";
    in
    self.lib.mkNixos "x86_64-linux" "haldir" (
      {
        config,
        ...
      }:
      {
        imports = with self.modules.nixos; [
          haldir-disko
          ssh
        ];

        services = {
          # Login through the app or:
          # tailscale up --login-server headscale.amusingimpala.com
          # and following prompts / webpage prompts.
          headscale = {
            enable = true;
            address = "127.0.0.1";
            port = 8080;
            settings = {
              dns = {
                base_domain = "${mdnsSubdomain}.${baseDomain}";
                nameservers.global = [
                  "1.1.1.1"
                  "8.8.8.8"
                  "9.9.9.9"
                ];
              };
              logtail.enabled = false;
              server_url = "https://${domain}";
              unix_socket_permission = "0770";
            };
          };

          nginx.enable = true;
          nginx.virtualHosts.${domain} = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/" = {
                proxyPass = "http://${config.services.headscale.address}:${toString config.services.headscale.port}";
                proxyWebsockets = true;
              };
            };
          };
        };

        networking = {
          firewall.allowedTCPPorts = [
            80
            443
          ];
          interfaces.enp1s0.ipv6.addresses = [
            {
              address = ipv6Addr;
              prefixLength = 64;
            }
          ];
          useDHCP = true;
        };

        security = {
          acme = {
            acceptTerms = true;
            defaults.email = "admin@${baseDomain}";
          };
          sudo.wheelNeedsPassword = false;
        };

        users.users = {
          nixos = {
            extraGroups = [
              "headscale"
              "wheel"
            ];
            isNormalUser = true;
            openssh.authorizedKeys.keyFiles = map (key: ../../ssh/keys + "/${key}") [
              "lukemurray@finarfin.pub"
            ];
          };
        };

        nix.settings.trusted-users = [
          "nixos"
          "root"
        ];

        boot = {
          loader = {
            efi = {
              canTouchEfiVariables = true;
              efiSysMountPoint = "/boot/efi";
            };
            grub = {
              enable = true;
              efiSupport = true;
              device = "nodev";
            };
          };

          initrd.availableKernelModules = [
            "virtio_pci"
            "virtio_blk"
            "virtio_scsi"
            "sd_mod"
          ];
        };

        swapDevices = [
          {
            device = "/swapfile";
            size = 2 * 1024; # 2 GB
          }
        ];

        system.stateVersion = "26.11";
      }
    );

  cloudflare-dns.${baseDomain}.${headscaleSubdomain} = {
    A = map (content: { inherit content; }) [
      "108.61.194.113"
    ];
    AAAA = map (content: { inherit content; }) [
      ipv6Addr
    ];
  };
}
