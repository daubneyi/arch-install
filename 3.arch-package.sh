#!/bin/env -S bash -e -x

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

set -x   # ensure that commands are echoed
set -e   # exit on error


reflector --country 'Australia' --latest 200 --age 24 -p https -p http -p ftp --sort rate --save /etc/pacman.d/mirrorlist

sleep 5

pacstrap /mnt base base-devel linux linux-firmware efibootmgr systemd-swap sudo screen openssh nftables iwd wpa_supplicant dosfstools reflector cryptsetup btrfs-progs pacman-contrib git bash zsh fish intel-ucode vim vi ntfs-3g ntp ldns systemd-resolvconf snapper cronie

sleep 5

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

cp "$SCRIPTPATH/4.arch-chrooted-env.sh" /mnt/root/
cp "$SCRIPTPATH/arch-postinstall.sh" /mnt/root/
cp "$SCRIPTPATH/arch-post-packages.sh" /mnt/root/
ls -l /mnt/root
