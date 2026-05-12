-- # $menu = fuzzel
-- # $menu = tofi-drun --drun-launch=true

local terminal = "kitty"
local browser = "helium-browser"
local fileManager = "dolphin"
local menu = "rofi -modi drun -show drun"
local launcher = "rofi -dmenu"

local mainMod = "SUPER"
local shiftMod = "SUPER + SHIFT"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(shiftMod .. " + Q", hl.dsp.window.kill())
hl.bind(shiftMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | " .. launcher .. "| cliphist decode | wl-copy"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

hl.bind(mainMod .. " + SPACE", hl.dsp.window.fullscreen())

hl.bind(shiftMod .. " + SPACE", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("emacsclient --eval '(rond/type)'"))
hl.bind(shiftMod .. " + L", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))

hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("~/.config/hypr/scripts/gamemode.rb"))

-- # Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- https://github.com/hyprwm/Hyprland/blob/5e441cae538c9396f2ee30338419bec12969608c/example/hyprland.lua#L275-L279
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
  hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- # Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + W", hl.dsp.workspace.toggle_special("webcam"))
hl.bind(shiftMod .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pypr toggle term")) -- toggles the "term" scratchpad visibility
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("pypr expose")) -- exposes every window temporarily or "jump" to the fucused one
-- hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("pypr change_workspace -1")) -- alternative multi-monitor workspace switcher
-- hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("pypr change_workspace +1")) -- alternative multi-monitor workspace switcher
-- hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("pypr toggle_special minimized")) -- toggle a window from/to the "minimized" special workspace
-- # bind = $mainMod SHIFT, N, togglespecialworkspace, minimized   # toggle the "minimized" special workspace visibility
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("pypr shift_monitors +1")) -- swaps workspaces between monitors
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("pypr zoom ++0.5")) -- zooms in the focused workspace
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("pypr zoom")) -- toggle zooming

-- # Screenshot a window
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("hyprcap rec -o ~/.hyprcap -c"))
-- # Screenshot a monitor
hl.bind("PRINT", hl.dsp.exec_cmd("hyprcap shot -z -o ~/.hyprcap -c"))
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd("hyprcap shot window:active -z -o ~/.hyprcap -c"))
-- # Screenshot a region
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("hyprcap shot region -z -o ~/.hyprcap -c"))

hl.bind(mainMod .. " + E", hl.dsp.submap("emacs"))
hl.define_submap("emacs", "reset", function()
  hl.bind("A", hl.dsp.exec_cmd("emacsclient --eval '(emacs-everywhere)'"))
  hl.bind("E", hl.dsp.exec_cmd("emacsclient -ca 'emacs'"))
  hl.bind("C", hl.dsp.exec_cmd("emacsclient -ca 'emacs'"))
  hl.bind("D", hl.dsp.exec_cmd("emacs --with-profile doom"))
  hl.bind("V", hl.dsp.exec_cmd("emacs --with-profile spacemacs"))
  hl.bind("S", hl.dsp.exec_cmd("emacs --with-profile simpa --debug-init"))
  hl.bind("N", hl.dsp.exec_cmd("emacs --with-profile elpaca"))
  hl.bind("G", hl.dsp.exec_cmd("emacs -u rond --init-directory ~/.config/gkmacs"))
  hl.bind("escape", hl.dsp.submap("reset"))
end)
