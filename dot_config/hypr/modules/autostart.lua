hl.on("hyprland.start", function()
  hl.exec_cmd("/home/rond/.config/hypr/scripts/rainbow-borders.sh")
  hl.exec_cmd("/home/rond/.config/hypr/scripts/import-gsettings")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("swaync")
  hl.exec_cmd("blueman-applet")

  -- # hl.exec_cmd("qs")

  hl.exec_cmd("ashell")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("$browser")
  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("steam --silent")

  -- # Start pyprland daemon
  hl.exec_cmd("pypr")

  hl.exec_cmd("heroic")
  hl.exec_cmd("udiskie")
  hl.exec_cmd("solaar -w hide")
  -- # hl.exec_cmd("emacs --daemon &")
  hl.exec_cmd("[workspace special silent] emacs --eval '(server-start)'")

  -- # hl.exec_cmd("/home/rond/.local/bin/clipboard-sync.sh &")
  -- # hl.exec_cmd("waypaper-engine daemon")
  -- # hl.exec_cmd(" /home/rond/.config/hypr/scripts/sleep.sh")

  hl.exec_cmd("vesktop")

  hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Purple-Dark-Compact'") -- for GTK3 apps
  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'") -- for GTK4 apps
end)
