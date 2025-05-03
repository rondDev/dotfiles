fish_add_path -U ~/.local/bin ~/.local/share/mise/shims ~/.config/tmux/plugins/t-smart-tmux-session-manager/bin ~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/
set -g EDITOR m
if status is-interactive
    # Commands to run in interactive sessions can go here
  alias m=mbn
  alias ls=lsd
  alias ll="lsd -lA"
  function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
      builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
  end
end
