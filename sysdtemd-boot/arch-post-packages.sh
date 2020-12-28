
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
