#
#
# ~/.bashrc
#
# If not running interactively, don't do anything

[[ $- != *i* ]] && return


alias htop='btm'
alias ls='eza'
alias ll='eza -la'
alias grep='grep --color=auto'
alias pac='sudo pacman -S'
alias bakkes="protontricks -c 'wine \"/home/$USER/.steam/steam/steamapps/compatdata/252950/pfx/drive_c/Program Files/BakkesMod/BakkesMod.exe\"' 252950"
alias bakke="protontricks -c 'wine ~/.scripts/inject.exe' 252950"
alias v="nvim"
# alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
# alias nvim-kick="NVIM_APPNAME=kickstart nvim"
# alias nvim-chad="NVIM_APPNAME=NvChad nvim"
# alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
# alias nvim-doom="NVIM_APPNAME=doom.nvim nvim"
# alias nvim-go2one="NVIM_APPNAME=go2one nvim"
# alias nvim-ecovim="NVIM_APPNAME=ecovim nvim"
# alias nvim-raphnvim="NVIM_APPNAME=raphnvim nvim"
# alias nvim-lvimide="NVIM_APPNAME=lvimide nvim"
# alias zr="zellij-runner"
# alias webcam="gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 /dev/video0"
# alias start_dslr='pkill -f gphoto2 && gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 /dev/video0'
alias ask="ollama run codellama"
alias askb="ollama run dolphin-mixtral:latest"
alias ghostbuild="zig build -p $HOME/.local -Doptimize=ReleaseFast"
alias c="cd"
alias taskmanager="missioncenter"
alias rem="neofetch --config ~/.config/neofetch/rem.conf"
alias venv="python -m venv ."
alias fakemacs="~/.config/fakemacs/bin/doom run" # doom emacs
PS1='[\u@\h \W]\$ '

export GTK_THEME="Orchis:dark"

function nvims() {
  items=("default" "kickstart" "LazyVim" "NvChad" "AstroNvim" "doom.nvim" "go2one" "ecovim" "raphnvim" "lvimide")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config 10 " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}

bindkey -e

# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/magic-enter"
plug "joshskidmore/zsh-fzf-history-search"

# plug "lukechilds/zsh-nvm"

# MAGIC_ENTER_GIT_COMMAND='git status -u .'
MAGIC_ENTER_GIT_COMMAND='exa -la .'
MAGIC_ENTER_OTHER_COMMAND='exa -la .'

export ZAP_GIT_PREFIX="git@github.com:"
# Load and initialise completion system
autoload -Uz compinit
compinit

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

function run_tmux() {
  if [ "$TERM" != "linux" ]
  then
    { tmux attach || exec tmux new-session && exit;}
  fi
}

function f() {
  t
}

zle -N f

if [[ -z $TMUX ]]
then
  bindkey -s "^f" "tmux\n"
else
  bindkey "^f" f
  # bindkey "^f" tmux-sessionizer
fi


bindkey '^n' clear-screen

eval "$(/home/$USER/.local/bin/mise activate zsh)"
