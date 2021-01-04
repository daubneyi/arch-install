#!/bin/evn -S bash -e -x

username=""

usage() {                                      # Function: Print a help message.
  echo "Usage: $0 [ -u USERNAME ]" 1>&2 
}

exit_abnormal() {                              # Function: Exit with error.
  usage
  exit 1
}

while getopts "u:" option; do
   case "${option}"
      in
         u) username=${OPTARG};;
	 :) exit_abnormal;;
   esac
done

useradd --create-home --user-group --groups wheel --shell /usr/bin/fish ${username}

systemctl enable --now NetworkManager.service

#echo "[Match]" > /etc/systemd/network/25-wireless.network
#echo "Name=$wifiint" >> /etc/systemd/network/25-wireless.network
#echo "" >> /etc/systemd/network/25-wireless.network
#echo "[Network]" >> /etc/systemd/network/25-wireless.network
#echo "DHCP=yes" >> /etc/systemd/network/25-wireless.network

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

#systemctl enable --now iwd.service
systemctl enable --now sshd.service

#iwctl station $wifiint scan
#iwctl station $wifiint get-networks
#iwctl --passphrase $wifipsk station $wifiint connect $wifissid

#systemctl enable --now systemd-networkd.service

#systemctl enable --now systemd-resolved.service
#ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

reflector --country 'Australia' --latest 20 --age 24 -p https -p http -p ftp --sort rate --save /etc/pacman.d/mirrorlist

pacman -S xorg
pacman -S xf86-video-intel mesa

Xorg :0 -configure

pacman -S lightdm


#su - ${username} <<SUEOF
#git clone https://aur.archlinux.org/yay.git $HOME/yay/
#cd $HOME/yay/
#makepkg -si

#yay lightdm-slick-greeter -S
#SUEOF
