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
  "~/.config/tmux/plugins/t-smart-tmux-session-manager/bin"
  "~/.local/share/mise/shims/"
])
$env.RIPGREP_CONFIG_PATH = "~/.config/ripgrep/ripgreprc"


let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

let fish_completer = {|spans|
  fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
  | from tsv --flexible --noheaders --no-infer
  | rename value description
  | update value {|row|
    let value = $row.value
    let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
    if ($need_quote and ($value | path exists)) {
      let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
      $'"($expanded_path | str replace --all "\"" "\\\"")"'
    } else {$value}
  }
}

# ' idk why this fixes syntax highlighting

let zoxide_completer = {|spans|
 $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
}


let tldr_completer = {|spans|
 $spans | skip 1 | tldr -l ...$in | lines | where {|x| $x =~ $spans.1}
}

# This completer will use carapace by default
let external_completer = {|spans|
  let expanded_alias = scope aliases
  | where name == $spans.0
  | get -o 0.expansion

  let spans = if $expanded_alias != null {
    $spans
    | skip 1
    | prepend ($expanded_alias | split row ' ' | take 1)
  } else {
    $spans
  }

  match $spans.0 {
    # carapace completions are incorrect for nu
    nu => $fish_completer
    # fish completes commits and branch names in a nicer way
    git => $fish_completer
    # carapace doesn't have completions for asdf
    asdf => $fish_completer
    paru => $fish_completer
    yay => $fish_completer
    pacman => $fish_completer
    # tldr => $tldr_completer
    z => $zoxide_completer
    _ => $carapace_completer
  } | do $in $spans
}

const NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
  ...$NU_PLUGIN_DIRS
]

$env.LS_COLORS = "di=1;34:*.nu=3;33;26"

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
        cmd: $"source '($nu.env-path)';source '($nu.config-path)'; echo 'reloaded'"
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
  completions: {
    use_ls_colors: true
    external: {
      enable: true
      completer: $external_completer
    }
  }
menus: [
    {
      name: completion_menu
      only_buffer_difference: false
      marker: "| "
      type: {
        layout: columnar # or "description" to see descriptions on the right
        columns: 4
        col_width: 20
        col_padding: 2
      }
      style: {
        text: green
        selected_text: cyan
        description_text: blue
      }
    }
  ]
}
