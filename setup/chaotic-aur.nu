#!/usr/bin/env nu
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'


if (grep -i "chaotic-aur" /etc/pacman.conf | wc -l | into int) < 1 { 
  sudo echo -e "\n[chaotic-aur]" | sudo tee -a /etc/pacman.conf
  sudo echo -e "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
} else {
  print "/etc/pacman.conf already contains the string 'chaotic-aur'"
}
