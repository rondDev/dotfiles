hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 20,

    border_size = 2,

    -- https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
    -- col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col = { active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg" },
    col = { inactive_border = "rgba(595959aa)" },

    -- Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,

    -- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = true,

    layout = "dwindle",
  },

  cursor = {
    no_hardware_cursors = true,
  },

  -- https://wiki.hyprland.org/Configuring/Variables/#decoration
  decoration = {
    rounding = 10,

    -- Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 1.0,

    -- drop_shadow = true,
    -- shadow_range = 4,
    -- shadow_render_power = 3,
    -- col.shadow = "rgba(1a1a1aee)",

    -- https://wiki.hyprland.org/Configuring/Variables/#blur
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      popups = true,

      vibrancy = 0.1696,
    },
  },

  -- https://wiki.hyprland.org/Configuring/Variables/#animations
  animations = {
    enabled = true,
    -- enabled = false

    -- Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
  },

  -- See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
  dwindle = {
    -- pseudotile = true, -- Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true, -- You probably want this
  },

  -- See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
  master = {
    new_status = "master",
  },

  -- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
  scrolling = {
    -- fullscreen_on_one_column = true,
  },

  render = {
    -- cm_fs_passthrough = 1,
    -- cm_auto_hdr = 2,
    send_content_type = false,
  },

  -- https://wiki.hyprland.org/Configuring/Variables/#misc
  misc = {
    force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
    middle_click_paste = false,
    vrr = 2,
  },

  -- #############
  -- ### INPUT ###
  -- #############

  -- https://wiki.hyprland.org/Configuring/Variables/#input
  input = {
    kb_layout = "us,no",
    kb_variant = "",
    kb_model = "",
    kb_options = "grp:alt_space_toggle, compose:caps",
    kb_rules = "",

    follow_mouse = 1,

    -- sensitivity = -0.8 # -1.0 - 1.0, 0 means no modification.
    sensitivity = 0, -- MX Master 3S -1.0 - 1.0, 0 means no modification.
    accel_profile = "flat",
    force_no_accel = true,

    touchpad = {
      natural_scroll = false,
    },
  },

  -- https://wiki.hyprland.org/Configuring/Variables/#gestures
  -- Outdated: 21 sept 2025
  -- gestures {
  --     workspace_swipe = false
  -- }

  -- Example per-device config
  -- See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
  -- device = {
  --   name = "epic-mouse-v1",
  --   sensitivity = -0.5,
  -- },
  debug = {
    damage_tracking = 0,
  },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
