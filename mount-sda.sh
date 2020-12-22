#!/usr/bin/bash -e

mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@root /dev/sda2 /mnt
mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@var /dev/sda2 /mnt/var
mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@usr /dev/sda2 /mnt/usr
mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,ssd,compress=zstd,space_cache,commit=120,subvol=@swap /dev/sda2 /mnt/swap
swapon /mnt/swap/swapfile
mount -t vfat /dev/sda1 /mnt/boot
