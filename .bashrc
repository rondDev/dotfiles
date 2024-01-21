#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -la --color=auto'
alias grep='grep --color=auto'
alias pac='sudo pacman -S'
alias bakkes="protontricks -c 'wine \"/home/$USER/.steam/steam/steamapps/compatdata/252950/pfx/drive_c/Program Files/BakkesMod/BakkesMod.exe\"' 252950"
alias bakke="protontricks -c 'wine ~/.scripts/inject.exe' 252950"
PS1='[\u@\h \W]\$ '
# source /usr/share/nvm/init-nvm.sh

export PATH="$PATH:/home/rond/.local/bin"
export EDITOR=nvim

#zsh
