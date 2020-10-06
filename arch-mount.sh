#!/bin/env -S bash -ex

usage() {                                      # Function: Print a help message.
  echo "Usage: $0 harddrive" 1>&2 
}
exit_abnormal() {                              # Function: Exit with error.
  usage
    exit 1
}
set -x   # ensure that commands are echoed
set -e   # exit on error

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

cryptsetup open ${1}${part}2 luks

# nmount /dev/mapper/luks /mnt
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@root /dev/mapper/luks /mnt
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@usr /dev/mapper/luks /mnt/usr
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var /dev/mapper/luks /mnt/var
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home /dev/mapper/luks /mnt/home
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@swap /dev/mapper/luks /mnt/swap
mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@snapshots /dev/mapper/luks /mnt/.snapshots
mount ${1}${part}1 /mnt/boot

swapon /mnt/swap/swapfile

free

