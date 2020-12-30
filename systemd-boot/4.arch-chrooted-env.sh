#!/bin/env -S bash -ex

usage() {                                      # Function: Print a help message.
  echo "Usage: $0 harddrive" 1>&2 
}
exit_abnormal() {                              # Function: Exit with error.
  usage
    exit 1
}
if [ -z $1 ]; then            # If the disk descriptor is empty:
   echo "Error: disk descriptor must be set as the first argument"
   exit_abnormal                          # Exit abnormally.
else
    if [[ $1 == *"nvme"* ]]; then
        part="p"
    else
        part=""
    fi
fi

set -x   # ensure that commands are echoed
set -e   # exit on error

bold=$(/usr/bin/tput bold)
underline=$(/usr/bin/tput smul)
normal=$(/usr/bin/tput sgr0)

ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
ls -l /etc/localtime

hwclock --systohc
hwclock --show --localtime

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_AU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo LANG=en_US.UTF-8 >> /etc/locale.conf
cat /etc/locale.conf

echo arch-XPS13 > /etc/hostname

cat /etc/hostname

echo "127.0.0.1    localhost" > /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    arch-XPS13.int.daubs.xyz arch-XPS13" >> /etc/hosts

cat /etc/hosts

sed -i 's#BINARIES=()#BINARIES=(/usr/bin/btrfs)#g' /etc/mkinitcpio.conf

#sed -i 's/^HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base keyboard udev autodetect modconf block keymap encrypt btrfs filesystems usr fsck)/g' /etc/mkinitcpio.conf
sed -i 's/^HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base keyboard udev autodetect modconf block keymap encrypt btrfs filesystems fsck)/g' /etc/mkinitcpio.conf

mkinitcpio -P

bootctl --path=/boot install

echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=UUID=`blkid -s UUID -o value ${1}${part}2`:luks:allow-discards root=/dev/mapper/luks rootflags=subvol=@root rd.luks.options=discard fsck.mode=force fsck.repair=yes rw" >> /boot/loader/entries/arch.conf


echo "default  arch.conf" > /boot/loader/loader.conf
echo "timeout 5" >> /boot/loader/loader.conf
echo "console-mode auto" >> /boot/loader/loader.conf
echo "editor no" >> /boot/loader/loader.conf


mkdir -p /etc/pacman.d/hooks/
echo "[Trigger]" > /etc/pacman.d/hooks/100-systemd-boot.hook
echo "Type = Package" >> /etc/pacman.d/hooks/100-systemd-boot.hook
echo "Operation = Upgrade" >> /etc/pacman.d/hooks/100-systemd-boot.hook
echo "Target = systemd" >> /etc/pacman.d/hooks/100-systemd-boot.hook
echo "" >> /etc/pacman.d/hooks/100-systemd-boot.hook
echo "[Action]" >> /etc/pacman.d/hooks/100-systemd-boot.hook
echo "Description = Upgrading systemd-boot" >> /etc/pacman.d/hooks/100-systemd-boot.hook
echo "When = PostTransaction" >> /etc/pacman.d/hooks/100-systemd-boot.hook
echo "Exec = /usr/bin/bootctl update" >> /etc/pacman.d/hooks/100-systemd-boot.hook

echo "You are almost set to proceed to reboot. 
echo "Don't forget to ${underline} set a root password ${normal} ${bold}Or you risk not being able to login${normal}"
