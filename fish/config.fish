set PATH $HOME/.cargo/bin $PATH
set PATH $HOME/.local/share/JetBrains/Toolbox/scripts $PATH

set -gx NVM_DIR "$HOME/.nvm"

if test -d "$NVM_DIR/versions/node"
    set -l node_versions (ls $NVM_DIR/versions/node)
    if count $node_versions >0
        set -l latest_node $node_versions[-1]
        set -gx PATH "$NVM_DIR/versions/node/$latest_node/bin" $PATH
    end
end

set fish_greeting ""

function camera
    mplayer tv:// -tv driver=v4l2:width=2560:height=1440:fps=60 -vo xv
end

function postman
    /bin/Postman/./Postman
end

function android-studio
    /opt/android-studio/bin/./studio.sh
end

function sshadd
    eval (ssh-agent -c)
end

function code
    /usr/bin/./code-insiders $argv
end

function ls
    lsd $argv
end

function cat
    bat --theme=Dracula $argv
end

function catn
    cat --style="changes" $argv
end

set zoxide_config $HOME/.config/fish/zoxide-conf.fish
test -r $zoxide_config; and source $zoxide_config

abbr --erase cd &>/dev/null
alias cd=__zoxide_z

abbr --erase cdi &>/dev/null
alias cdi=__zoxide_zi

atuin init fish | source
starship init fish | source
zoxide init fish | source

if status is-interactive
    if not set -q ZELLIJ
        zellij
    else
        nitch; and cmatrix -s -b; and atuin sync
    end
end
