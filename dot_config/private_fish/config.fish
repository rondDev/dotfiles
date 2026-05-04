abbr -a fish-reload-config 'source ~/.config/fish/**/*.fish'
# abbr -a ghc 'git clone git@github.com:'
abbr -a tmx tmuxifier
abbr -a nproj 'mkdir ~/code/'
# abbr -a gs 'git status'
abbr -a gcm 'git commit -m'
abbr -a cb 'cargo build'
abbr -a cr 'cargo run'
abbr -a crr 'cargo run --release'
abbr -a cbr 'cargo build --release'
abbr -a ct 'cargo test'
alias s='kitten ssh'
alias tm='tmuxifier'
alias ls='exa'
alias ll='ls -lah'
alias lgit='lazygit'
alias lg='lazygit'
set --global hydro_cmd_duration_threshold 1
set --universal hydro_fetch true
set -U fish_greeting
set -gx EDITOR nvim
set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgreprc
if status is-interactive
    # Commands to run in interactive sessions can go here
    set -U FZF_COMPLETE 3
    set -U __done_kitty_remote_control 1
    set -U __done_kitty_remote_control_password kitty-rc-password

    function ll
        ls -l $argv
    end
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    # function ghc -d "Clone a repo via github SSH (format: user/repo)"
    #     git clone git@github.com:$argv
    # end


    # function fish_prompt
    #     set -l last_status $status
    #     #     Prompt status only if it's not 0
    #     set -l stat
    #     if test $last_status -ne 0
    #         set stat (set_color red)"[$last_status]"(set_color normal)
    #     end

    #     string join '' -- (set_color green) (prompt_pwd) (set_color normal) $stat '>'
    # end

    # function fish_right_prompt
    #     set -l last_status $status
    #     #     Prompt status only if it's not 0
    #     set -l stat
    #     if test $last_status -ne 0
    #         set stat (set_color red)"[$last_status]"(set_color normal)
    #     end

    #     __bobthefish_cmd_duration

    #     __bobthefish_timestamp


    #     string join '' $fish_vcs_prompt $stat ''
    #     set -e stat
    # end
    function fzf-complete -d 'fzf completion and print selection back to commandline'
        # As of 2.6, fish's "complete" function does not understand
        # subcommands. Instead, we use the same hack as __fish_complete_subcommand and
        # extract the subcommand manually.
        set -l cmd (commandline -co) (commandline -ct)
        switch $cmd[1]
            case env sudo
                for i in (seq 2 (count $cmd))
                    switch $cmd[$i]
                        case '-*'
                        case '*=*'
                        case '*'
                            set cmd $cmd[$i..-1]
                            break
                    end
                end
        end
        set cmd (string join -- ' ' $cmd)

        set -l complist (complete -C$cmd)
        set -l result
        string join -- \n $complist | sort | eval (__fzfcmd) -m --select-1 --exit-0 --header '(commandline)' | cut -f1 | while read -l r
            set result $result $r
        end

        set prefix (string sub -s 1 -l 1 -- (commandline -t))
        for i in (seq (count $result))
            set -l r $result[$i]
            switch $prefix
                case "'"
                    commandline -t -- (string escape -- $r)
                case '"'
                    if string match '*"*' -- $r >/dev/null
                        commandline -t -- (string escape -- $r)
                    else
                        commandline -t -- '"'$r'"'
                    end
                case '~'
                    commandline -t -- (string sub -s 2 (string escape -n -- $r))
                case '*'
                    commandline -t -- (string escape -n -- $r)
            end
            [ $i -lt (count $result) ]; and commandline -i ' '
        end


        commandline -f repaint
    end
    function __bobthefish_cmd_duration -S -d 'Show command duration'
        [ "$theme_display_cmd_duration" = no ]
        and return

        [ -z "$CMD_DURATION" -o "$CMD_DURATION" -lt 100 ]
        and return

        if [ "$CMD_DURATION" -lt 5000 ]
            echo -ns $CMD_DURATION ms
        else if [ "$CMD_DURATION" -lt 60000 ]
            __bobthefish_pretty_ms $CMD_DURATION s
        else if [ "$CMD_DURATION" -lt 3600000 ]
            set_color $fish_color_error
            __bobthefish_pretty_ms $CMD_DURATION m
        else
            set_color $fish_color_error
            __bobthefish_pretty_ms $CMD_DURATION h
        end

        set_color $fish_color_normal
        set_color $fish_color_autosuggestion

        [ "$theme_display_date" = no ]
        or echo -ns ' ' $__bobthefish_left_arrow_glyph
    end

    function __bobthefish_pretty_ms -S -a ms -a interval -d 'Millisecond formatting for humans'
        set -l interval_ms
        set -l scale 1

        switch $interval
            case s
                set interval_ms 1000
            case m
                set interval_ms 60000
            case h
                set interval_ms 3600000
                set scale 2
        end
    end

    function __bobthefish_timestamp -S -d 'Show the current timestamp'
        [ "$theme_display_date" = no ]
        and return

        set -q theme_date_format
        or set -l theme_date_format "+%c"

        echo -n ' '
        set -q theme_date_timezone
        and env TZ="$theme_date_timezone" date $theme_date_format
        or date $theme_date_format
    end
end
function mkcd -d "Create directory and change to it"
    mkdir -pv $argv
    cd $argv
end

alias gs="git status"
alias rscript="scriptisto"


fish_add_path -ga $HOME/.cargo/bin
fish_add_path -ga $HOME/.nimble/bin
fish_add_path -ga $HOME/.nix-profile/bin
fish_add_path -ga /nix/var/nix/profiles/default/bin
fish_add_path -ga $HOME/.local/share/bob/nvim-bin
fish_add_path -ga $HOME/.local/share/gem/ruby/3.2.0/bin
fish_add_path -ga $HOME/.tmuxifier/bin
fish_add_path -ga $HOME/.bun/bin
# fish_add_path -ga $HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/
fish_add_path -ga $HOME/.local/bin/platform-tools/
fish_add_path -ga $HOME/.config/herd-lite/bin/
fish_add_path -ga $HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin
fish_add_path -ga $HOME/.local/share/mise/shims/
# THIS FIXES LOCALE ISSUES WITH NIX
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

eval (tmuxifier init - fish)
fifc \
    -r '^(pacman|paru)(\\h*\\-S)?\\h+' \
    -s 'pacman --color=always -Ss "$fifc_token" | string match -r \'^[^\\h+].*\'' \
    -e '.*/(.*?)\\h.*' \
    -f "--query ''" \
    -p 'pacman -Si "$fifc_extracted"'

direnv hook fish | source
# /usr/local/sbin
# /usr/local/bin
# /usr/bin
# /usr/bin/site_perl
# /usr/bin/vendor_perl
# /usr/bin/core_perl

fish_add_path /home/rond/.millennium/ext/bin
/home/rond/.local/bin/mise activate fish | source
~/.local/bin/mise activate fish | source
starship init fish | source
set -gx PATH "$PATH:/home/rond/.cache/scalacli/local-repo/bin/scala-cli"
