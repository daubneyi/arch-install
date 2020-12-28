#!/bin/evn -S bash -e -x

wifiint=""
wifissid=""
wifipsk=""

usage() {                                      # Function: Print a help message.
  echo "Usage: $0 [ -i WIFI_INT_NAME ] [ -s SSID ] [ -p PSK]" 1>&2 
}

exit_abnormal() {                              # Function: Exit with error.
  usage
  exit 1
}

while getopts "i:s:p:" option; do
   case "${option}"
      in
         i) wifiint=${OPTARG};;
         s) wifissid=${OPTARG};;
         p) wifipsk=${OPTARG};;
	 :) exit_abnormal;;
   esac
done



systemctl enable --now iwd.service

echo "[Match]" > /etc/systemd/network/25-wireless.network
echo "Name=$wifiint" >> /etc/systemd/network/25-wireless.network
echo "" >> /etc/systemd/network/25-wireless.network
echo "[Network]" >> /etc/systemd/network/25-wireless.network
echo "DHCP=yes" >> /etc/systemd/network/25-wireless.network

iwctl --passphrase $wifipsk station $wifiint connect $wifissid
systemctl enable --now systemd-networkd.service
systemctl enable --now systemd-resolved.service
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

git clone https://aur.archlinux.org/yay.git /root/yay/
cd /root/yay/
makepkg -si
cd -

pacman -S lightdm

yay lightdm-slick-greeter -S
