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
$env.ZDOTDIR = $"($env.HOME)/.config/zsh"
$env.PATH = ($env.PATH | split row (char esep) | append [
  "~/bin"
  "/home/rond/.local/bin"
  "/nix/var/nix/profiles/default/bin"
  "~/.nix-profile/bin"
  "~/.local/share/bob/nvim-bin"
  "~/.local/share/gem/ruby/3.4.0/bin"
  "~/.tmuxifier/bin"
  "~/.bun/bin"
  "~/.cargo/bin"
  "~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/"
  "~/.local/bin/platform-tools/"
  "~/.config/tmux/plugins/t-smart-tmux-session-manager/bin"
  "~/.local/share/mise/shims/"
])
$env.RIPGREP_CONFIG_PATH = $"($env.HOME)/.config/ripgrep/ripgreprc"
$env.EDITOR = "emacsclient"


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
# Define a custom completer function that pipes into television
let tv_completer = {|spans|
    # Convert command line arguments to a single string
    let query = ($spans | str join " ")
    
    # Run television using its standard input/smart channel mode
    # Adjust flags based on your preference (e.g., --preview if supported)
    let selected = (echo $query | tv --autocomplete-mode | decode utf-8 | str trim)
    
    if ($selected | is-empty) {
        []
    } else {
        [$selected]
    }
}

let television_global_completer = {|spans|
    # 1. Grab the last typed word fragment to prime Television's interactive query
    let last_word = ($spans | last | str trim)
    
    # 2. Invoke the true internal autocomplete engine via the commandline module
    # 3. Extract the clean 'value' column from Nushell's completion records
    let raw_options = (commandline complete | get value | str join "\n")

    # Exit gracefully if Nushell has no suggestions for the current string
    if ($raw_options | is-empty) {
        return []
    }

    # 4. Use 'encode utf-8' to output a raw binary byte stream into Television
    let selection = ($raw_options | encode utf-8 | tv --passthrough --query $last_word | decode utf-8 | str trim)

    if ($selection | is-empty) {
        []
    } else {
        [$selection]
    }
}




# This completer will use carapace by default
let external_completer = {|spans|
  let expanded_alias = scope aliases
  | where name == $spans.0
  | get -o 0.expansion

#   let spans = if $expanded_alias != null {
#     $spans
#     | skip 1
#     | prepend ($expanded_alias | split row ' ' | take 1)
#   } else {
#     $spans
#   }

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
    # {
    #   name: completion_menu
    #   modifier: control
    #   keycode: char_t
    #   mode: emacs
    #   event: { send: menu name: completion_menu }
    # },
    # {
    #   name: tv_autocomplete
    #   modifier: none
    #   keycode: tab
    #   mode: [emacs, vi_normal, vi_insert]
    #   event: {
    #   send: executehostcommand
    #   cmd: "commandline edit --insert (tv autocomplete (commandline))"
    #         }
    # },
    {
      name: fzf_history
      modifier: control
      keycode: char_r
      mode: [emacs, vi_insert, vi_normal]
      event: [
        {
          send: ExecuteHostCommand
          # Fetches unique history items, feeds them to fzf, and inserts the choice
          cmd: "commandline edit --insert (history | each { get command } | uniq | reverse | str join (char nl) | fzf | str trim)"
        }
      ]
    },
    # {
    #     name: tv_tab_completion
    #     modifier: none
    #     keycode: tab
    #     mode: [emacs, vi_normal, vi_insert]
    #     event: { send: executehostcommand, cmd: "commandline complete" }
    # }
{
        name: completion_menu
        modifier: none
        keycode: tab
        mode: [emacs, vi_insert]
        event: {
            # Tells Nushell to cleanly open the completion menu using our external fzf definition
            until: [
                { send: menu name: completion_menu }
                { send: menunext }
            ]
        }
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
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy" # Matches the fuzzy search logic of fzf
    external: {
        enable: true
        # Emulates fzf-tab fallback using your native carapace tool
        completer: $external_completer
        }
  }
}

devenv hook nu | save --force ~/.cache/devenv/hook.nu
source ~/.cache/devenv/hook.nu

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

mkdir ($nu.data-dir | path join "vendor/autoload")
tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")


$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
source $"($nu.cache-dir)/carapace.nu"

source $"($nu.default-config-dir)/aliases.nu"
source $"($nu.default-config-dir)/extra/sdkman.nu"
source $"($nu.default-config-dir)/extra/zoxide.nu"


overlay use ~/.config/nushell/extra/alias-finder.nu
