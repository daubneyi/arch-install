#!/bin/evn -S bash -e -x

wifiint=""
wifissid=""
wifipsk=""
username=""

usage() {                                      # Function: Print a help message.
  echo "Usage: $0 [ -i WIFI_INT_NAME ] [ -s SSID ] [ -p PSK] [ -u USERNAME ]" 1>&2 
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
         u) username=${OPTARG};;
	 :) exit_abnormal;;
   esac
done

useradd --create-home --groups wheel --user-group --shell /usr/bin/fish ${username}

systemctl enable --now iwd.service

echo "[Match]" > /etc/systemd/network/25-wireless.network
echo "Name=$wifiint" >> /etc/systemd/network/25-wireless.network
echo "" >> /etc/systemd/network/25-wireless.network
echo "[Network]" >> /etc/systemd/network/25-wireless.network
echo "DHCP=yes" >> /etc/systemd/network/25-wireless.network

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

systemctl enable --now iwd.service
systemctl enable --now sshd.service

iwctl --passphrase $wifipsk station $wifiint connect $wifissid
systemctl enable --now systemd-networkd.service
systemctl enable --now systemd-resolved.service
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

pacman -S xorg
pacman -S xf86-video-intel mesa

Xorg :0 -configure

pacman -S lightdm
pacman -S lightdm

su - ${username} <<SUEOF
git clone https://aur.archlinux.org/yay.git $HOME/yay/
cd $HOME/yay/
makepkg -si

yay lightdm-slick-greeter -S
SUEOF
