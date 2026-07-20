{
  self,
  ...
}:
{
  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "glorfindel" (
    {
      pkgs,
      ...
    }:
    {
      imports = with self.modules.nixos; [
        glorfindel-hardware
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.networkmanager.enable = true;

      time.timeZone = "America/Phoenix";
      i18n.defaultLocale = "en_US.UTF-8";

      services = {
        xserver.enable = true;

        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;

        xserver.xkb = {
          layout = "us";
          variant = "";
        };

        printing.enable = true;

        pulseaudio.enable = false;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
      };

      security.rtkit.enable = true;

      users.users.lukemurray = {
        shell = pkgs.zsh;
        isNormalUser = true;
        description = "Luke Murray";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      programs.zsh.enable = true;

      programs.firefox.enable = true;

      system.stateVersion = "24.11";
    }
  );
}
