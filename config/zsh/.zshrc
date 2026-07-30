# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/rond/.zsh/completions:"* ]]; then export FPATH="/home/rond/.zsh/completions:$FPATH"; fi
# Keep PATH unique and clean up duplicates automatically
typeset -U path PATH

# Define GEM_HOME needed for Ruby gems
export GEM_HOME="$HOME/.gems"

# Zsh native path array
path=(
  "$HOME/bin"
  "$HOME/.ghcup/bin"
  "$HOME/.local/share/gem/ruby/3.4.0/bin"
  "/home/rond/.local/bin"
  "/home/rond/.cargo/bin"
  "/home/rond/.nimble/bin"
  "/home/rond/.nix-profile/bin"
  "/nix/var/nix/profiles/default/bin"
  "/home/rond/.local/share/bob/nvim-bin"
  "/home/rond/.tmuxifier/bin"
  "/home/rond/.bun/bin"
  "/home/rond/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/"
  "/home/rond/.local/bin/platform-tools/"
  "/home/rond/.config/herd-lite/bin/"
  "/home/rond/.config/tmux/plugins/t-smart-tmux-session-manager/bin"
  "/home/rond/.local/share/mise/shims/"
  "$GEM_HOME/bin"
  
  $path
)

# Fix Delete Key
bindkey "^[[3~" delete-char

# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug 'twfksh/zsh-ssh-agent'
plug "Aloxaf/fzf-tab"
plug 'joshskidmore/zsh-fzf-history-search'

LC_CTYPE=en_US.UTF-8
LC_ALL=en_US.UTF-8

alias nnn='~/bin/nnn -de' # -d for details and -e to open files in $VISUAL (for other options, see 'man nnn'...)
alias gs="git status"
alias e="emacsclient -n"

#-----
export NNN_OPTS="H" # 'H' shows the hidden files. Same as option -H (so 'nnn -deH')
# export NNN_OPTS="deH" # if you prefer to have all the options at the same place
export LC_COLLATE="C" # hidden files on top
export NNN_FIFO="/tmp/nnn.fifo" # temporary buffer for the previews
export NNN_FCOLORS="AAAAE631BBBBCCCCDDDD9999" # feel free to change the colors
export NNN_PLUG='p:preview-tui' # many other plugins are available here: https://github.com/jarun/nnn/tree/master/plugins
export SPLIT='h' # to split Kitty vertically
export EDITOR='emacsclient -n'
#-----
n () # to cd on quit
{
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    nnn "$@"
    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

# Example globally setting the prefix for Zap to git clone using an SSH key
export ZAP_GIT_PREFIX="git@github.com:"

zsh-ssh-agent

# Load and initialise completion system
autoload -Uz compinit
compinit

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# bun completions
[ -s "/home/rond/.bun/_bun" ] && source "/home/rond/.bun/_bun"



. "/home/rond/.deno/env"
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
eval "$(devenv hook zsh)"
eval "$(starship init zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
