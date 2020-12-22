#!/usr/bin/bash -e

mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@root /dev/nvme0n1p2 /mnt
mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@var /dev/nvme0n1p2 /mnt/var
mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@usr /dev/nvme0n1p2 /mnt/usr
mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@swap /dev/nvme0n1p2 /mnt/swap
swapon /mnt/swap/swapfile
mount -t vfat /dev/nvme0n1p1 /mnt/boot
