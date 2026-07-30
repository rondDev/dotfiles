hl.window_rule({ match = { xwayland = true }, rounding = 0 })
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk)$" }, dim_around = true, no_blur = true, border_size = 0 })
hl.window_rule({ match = { class = "^(polkit-gnome-authentication-agent-1)$" }, dim_around = true })
hl.window_rule({ match = { class = "^(zen)$", title = "^(File Upload)$" }, dim_around = true })
local otterSize = { 410, 220 }
hl.window_rule({
  name = "otter-launcher",
  match = {
    class = "otter",
  },
  float = true,
  animation = "popin 80%",
  size = otterSize,
  opaque = true,
})

hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture in picture)$" }, float = true })

-- Bitwarden extension (Chromium)
hl.window_rule({ match = { class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default" }, float = true })
-- Raindrop extension (Chromium)
hl.window_rule({ match = { class = "chrome-ldgfbffkinooeloadekpmfoklnobpien-Default" }, float = true })

-- Bitwarden extension (Zen/Firefox, doesn't work)
hl.window_rule({ match = { title = "^(.*Bitwarden Password Manager.*)$" }, float = true })

-- gaming
hl.window_rule({
  match = { class = "^(osu!|cs2|Terraria.bin.x86_64|steam_app_1151340|warframe.x64.exe)$" },
  immediate = true,
})
hl.window_rule({
  match = { class = "^(warframe.x64.exe)$" },
  suppress_event = "fullscreen maximize",
  confine_pointer = true,
})
hl.window_rule({
  match = { title = "^(Fallout76)$" },
  immediate = true,
  confine_pointer = true,
  fullscreen_state = "3",
  maximize = true,
  fullscreen = true,
})
hl.window_rule({ match = { title = "^(Steam)$" }, workspace = "5 silent" })
hl.window_rule({ match = { title = "^(steam)$" }, float = true })

hl.window_rule({ match = { class = "^(Rofi)$" }, float = true, border_size = 0 })
hl.window_rule({ match = { class = "^(Pinentry-gtk)$" }, float = true })
hl.window_rule({ match = { class = "^(waypaper)$" }, float = true })
hl.window_rule({ match = { class = "^(PortProton)$" }, float = true })
hl.window_rule({ match = { class = "^(emacs|Emacs|kitty)$" }, opacity = "0.95 0.9" })
hl.window_rule({ match = { class = "^(vesktop)$" }, workspace = "6 silent" })
hl.window_rule({ match = { class = "^(virt-manager)$" }, workspace = "4 silent" })
hl.window_rule({ match = { class = "^(Spotify)$" }, workspace = "special:magic silent" })
hl.window_rule({ match = { class = "^(com.obsproject.Studio)$" }, workspace = "special:webcam silent" })

hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ match = { class = "^(one.alynx.showmethekey)$" }, float = true })
hl.window_rule({ match = { class = "^(showmethekey-gtk)$" }, float = true })
hl.window_rule({ match = { class = "(.*menu.*)" }, opacity = "1.0 override 1.0 override" })

hl.window_rule({ match = { class = "^(emacs)$", title = "^(emacs-float)$" }, float = true })
-- windowrule = float true,match:class ^(emacs)$,match:title ^(emacs-float)$ # Launch as a floating window.

hl.workspace_rule({ workspace = "1", monitor = "DP-3", default = true })
-- hl.workspace_rule({ workspace = "2", monitor = "DP-2", default = true })
hl.workspace_rule({ workspace = "6", default_name = "discord", monitor = "DP-2", default = true })
hl.workspace_rule({ workspace = "special:magic", on_created_empty = "spotify" })

-- workspace = 2, defaultName:2: work
-- workspace = 4, defaultName:4: virt-manager
-- workspace = 5, defaultName:5: games
-- workspace = 6, defaultName:6: discord
-- # workspace = name:"6: discord", monitor:DP-2, default:true
-- # workspace = name:coding, rounding:false, decorate:false, gapsin:0, gapsout:0, border:false, decorate:false, monitor:DP-1
-- workspace = special:magic, on-created-empty:spotify
-- # workspace = special:webcam, on-created-empty:obs & noisetorch
