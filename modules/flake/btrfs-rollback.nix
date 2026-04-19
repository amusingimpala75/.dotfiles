{
  lib,
  ...
}:
{
  # This submodules snapshots the root subvolume to
  # The snapshots subvolume, and regenerates an empty
  # one on boot. It also cleanups up the snapshots
  # subvolume to only keep the last 5
  flake.modules.nixos.btrfs-rollback =
    {
      config,
      pkgs,
      ...
    }:
    {
      options.boot.btrfs-rollback.device = lib.mkOption {
        type = lib.types.str;
        description = "device that is to be mounted as the btrfs root volume";
        example = "/dev/disk/by-id/ata-APPLE_SSD_SD0128F_141644410441";
      };
      config.boot.initrd.systemd = {
        services.btrfs-rollback = {
          description = "Rollback services with archives of old impermanent roots";
          unitConfig.DefaultDependencies = false;
          serviceConfig.Type = "oneshot";
          requiredBy = [ "initrd.target" ];
          before = [ "sysroot.mount" ];
          requires = [ "initrd-root-device.target" ];
          after = [
            "initrd-root-device.target"
            "local-fs-pre.target"
          ];
          script = ''
            # We don't want partial failures
            set -euo pipefail

            # Make the mount point
            mkdir -p /mnt

            # Mount the entire btrfs volume
            mount -t btrfs -o subvolid=5 ${config.boot.btrfs-rollback.device} /mnt

            # Make the snapshots subvolume if necessary
            if [ ! -e /mnt/snapshots ]
            then
              btrfs subvolume create /mnt/snapshots
            fi

            if [ -e /mnt/root ]
            then
              # Snapshot the root volume
              btrfs subvolume snapshot -r /mnt/root "/mnt/snapshots/root-$(date -u '+%Y-%m-%d_%H-%M-%S_UTC')"

              # Remove the old root
              btrfs subvolume delete --recursive /mnt/root
            fi

            # Create clean root subvolume
            btrfs subvolume create /mnt/root

            # Delete oldest snapshots, retaining last 5
            find /mnt/snapshots -mindepth 1 -maxdepth 1 -printf '%T@ %p\n' |
            sort -nr |
            awk 'NR>5' |
            while IFS= read -r snapshot
            do
              btrfs subvolume delete --recursive "''${snapshot#* }"
            done

            # Unmount the btrfs
            umount /mnt
          '';
        };
        extraBin = with pkgs; {
          "mkdir" = "${coreutils}/bin/mkdir";
          "btrfs" = "${btrfs-progs}/bin/btrfs";
          "date" = "${coreutils}/bin/date";
          "find" = "${findutils}/bin/find";
          "sort" = "${coreutils}/bin/sort";
          "awk" = "${gawk}/bin/awk";
          "mount" = lib.mkForce "${util-linux}/bin/mount";
          "umount" = lib.mkForce "${util-linux}/bin/umount";
        };
      };
    };
}
