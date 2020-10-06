#!/bin/env -S bash -e -x

wifiint="wlan0"
wifissid=""
wifipsk=""

bold=$(/usr/bin/tput bold)
underline=$(/usr/bin/tput smul)
normal=$(/usr/bin/tput sgr0)

usage() {                                      # Function: Print a help message.
	  echo "Usage: $0 [ -int WIFI_INT_NAME ] [ -ssid SSID ] [ -psk PSK]" 1>&2 
}

exit_abnormal() {                              # Function: Exit with error.
	  usage
	    exit 1
}

while getopts ":i:s:p:" option; do
	case "${option}"
		in
			i) wifiint=${OPTARG};;
			s) wifissid=${OPTARG};;
			p) wifipsk=${OPTARG};;
			:) exit_abnormal;;
	esac
done

#set -x   # ensure that commands are echoed
#set -e   # exit on error

#echo interface "$wifiint", ssid "$wifissid", psk "$wifipsk"

#if [ ! -z "$(ls -A /sys/firmware/efi/efivars > /dev/null 2>&1)" ]; then
#	echo "UEFI System mode"
#else
#	echo "ERROR: not UEFI System mode" ; exit 1
#fi
#sleep 5
#ls -l /sys/firmware/efi/efivars

/usr/bin/ping -4 -c 1 archlinux.org > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "cannot reach archlinux.org lets connect networks!"
	/usr/bin/bash ./connect-networks.sh -i "$wifiint" -s "$wifissid" -p "$wifipsk"
        /usr/bin/ip -4 addr show $wifiint
else
	echo "network appears connected!"
fi

/usr/bin/sleep 10

# Set NTP time
timedatectl set-ntp true
if [ $? -ne 0 ]; then
	echo "ERROR: cannot set ntp time"
exit 1;
else
	echo "System clock is set!"
fi

/usr/bin/sleep 10

# Update pacman and set for remote access
pacman -Syy && pacman --noconfirm -S screen openssh reflector
if [ $? -ne 0 ]; then
	echo "ERROR: couldn't update pacman"
	exit 1;
else
	IP=$(/usr/bin/ip -4 a show wlan0 | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | head -n 1)
	/usr/bin/systemctl start sshd.service
	echo "we are set to proceed via ssh once the ${underline}root password has been set${normal} ${bold}root@$IP${normal}"
fi

exit 0
