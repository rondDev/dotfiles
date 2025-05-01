#!/usr/bin/env nu
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
sudo rm -r ../yay
