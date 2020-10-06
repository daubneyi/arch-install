#!/bin/env -S bash -e -x

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

echo "We are running things on $1"

set -x   # ensure that commands are echoed
set -e   # exit on error

sgdisk -og $1
sgdisk -n 1:2048:1050624 -c 1:"EFI System Partition" -t 1:ef00 $1
#sgdisk -n 2:1050625:17827841 -c 2:"Linux swap" -t 2:8200 $1
ENDSECTOR=`sgdisk -E $1`
sgdisk -n 2:1050625:$ENDSECTOR -c 2:"Linux BTRFS" -t 2:8300 $1
#sgdisk -n 3:17827842:$ENDSECTOR -c 3:"Linux LVM" -t 3:8e00 $1
sgdisk -p $1

echo "set a strong password!"
modprobe dm-crypt 
modprobe dm-mod
sleep 5
cryptsetup --verbose luksFormat --type luks2 -v -s 512 -h sha512 ${1}${part}2

ls -l /dev/mapper

sleep 5
cryptsetup open ${1}${part}2 luks

sleep 5
echo "test your strong password!"
mkfs.btrfs -f -L ROOT /dev/mapper/luks

sleep 5
mount /dev/mapper/luks /mnt
sleep 5
btrfs sub create /mnt/@root
btrfs sub create /mnt/@usr
btrfs sub create /mnt/@var
btrfs sub create /mnt/@home
btrfs sub create /mnt/@swap
btrfs sub create /mnt/@snapshots
sleep 5
chattr +C /mnt/@swap
sleep 2 
btrfs property set /mnt/@swap compression none
sleep 2 
truncate -s 0 /mnt/@swap/swapfile
sleep 2 
fallocate -l 512M /mnt/@swap/swapfile
sleep 2 
chmod 600 /mnt/@swap/swapfile
sleep 2 
mkswap /mnt/@swap/swapfile
sleep 2 
umount /mnt
sleep 5

mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@root /dev/mapper/luks /mnt
sleep 5
mkdir -p /mnt/{boot,usr,var,home,swap,.snapshots}
sleep 5
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@usr /dev/mapper/luks /mnt/usr
sleep 2 
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var /dev/mapper/luks /mnt/var
sleep 2 
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home /dev/mapper/luks /mnt/home
sleep 2 
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@swap /dev/mapper/luks /mnt/swap
sleep 2 
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@snapshots /dev/mapper/luks /mnt/.snapshots

mkfs.fat -v -F32 -n EFI ${1}${part}1
sleep 5
mount ${1}${part}1 /mnt/boot
sleep 5

swapon /mnt/swap/swapfile
sleep 5
free


exit 0
