{
            disko.devices = {
              disk = {
                main = {
                  type = "disk";
                  device =
                    "/dev/disk/by-id/nvme-eui.00000000000000000c82d58020000000";
                  content = {
                    type = "gpt";
                    partitions = {
                      boot = {
                        size = "500M";
                        type = "EF00";
                        content = {
                          type = "filesystem";
                          format = "vfat";
                          mountpoint = "/boot";
                          mountOptions = [ "umask=0077" ];
                        };
                      };
                      primary = {
                        size = "100%";
                        content = {
                          type = "btrfs";
                          extraArgs = [ "-f" ]; # Override existing partition
                          subvolumes = {
                            "/rootfs" = { mountpoint = "/"; };
                            "/home" = {
                              mountOptions = [ "compress=zstd" ];
                              mountpoint = "/home";
                            };
                            "/home/wekuz" = { };
                            "/nix" = {
                              mountOptions = [ "compress=zstd" "noatime" ];
                              mountpoint = "/nix";
                            };
                          };

                          mountpoint = "/partition-root";
                        };
                      };
                    };
                  };
                };
              };
            };
          }
