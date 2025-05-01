#!/usr/bin/env nu
def "main reset-keys" [] {
  sudo rm -r /etc/pacman.d/gnupg/ | ignore
  sudo pacman-key --init
  sudo pacman-key --populate archlinux
  sudo pacman -Sc  # may or may not be necessary
  sudo pacman -Syyu
}

def main [] {
  print "Commands: "
  print "reset-keys     deletes and refreshes keyring keys"
}
