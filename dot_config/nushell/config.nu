# config.nu
#
# Installed by:
# version = "0.101.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.
$env.config.show_banner = false
$env.TMUX_POWERLINE_THEME = "my-theme"
$env.PATH = ($env.PATH | split row (char esep) | append [
"/nix/var/nix/profiles/default/bin"
"~/.nimble/bin"
"~/.nix-profile/bin"
"~/.local/share/bob/nvim-bin"
"~/.local/share/gem/ruby/3.2.0/bin"
"~/.tmuxifier/bin"
"~/.bun/bin"
"~/.cargo/bin"
"~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/"
"~/.local/bin/platform-tools/"
"~/.config/herd-lite/bin/"
"~/.config/tmux/plugins/t-smart-tmux-session-manager/bin"
"~/.local/share/mise/shims/"
])
$env.RIPGREP_CONFIG_PATH = "~/.config/ripgrep/ripgreprc"

$env.config = {
  # edit_mode: 'vi'
  keybindings: [
  {
    name: reload_config
    modifier: none
    keycode: f5
    mode: [emacs vi_normal vi_insert]
    event: {
      send: executehostcommand,
      cmd: $"source '($nu.env-path)';source '($nu.config-path)'"
    }
  },
 {
        name: completion_menu
        modifier: control
        keycode: char_t
        mode: emacs
        event: { send: menu name: completion_menu }
      }
  ]
hooks: {
    pre_prompt: [{ ||
      if (which direnv | is-empty) {
        return
      }

      direnv export json | from json | default {} | load-env
      if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
        $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
      }
    }]
  }
}

use ~/.config/nushell/extra/fuzzy_command.nu
