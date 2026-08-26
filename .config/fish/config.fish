source /usr/share/cachyos-fish-config/cachyos-config.fish

set -Ux LANG en_US.UTF-8
set -Ux LC_ALL en_US.UTF-8

function fish_title
    set -l cwd (basename "$PWD")
    printf '%s' "$cwd"
end

export EDITOR=nvim
export VISUAL=nvim

function fish_greeting
end

zoxide init fish | source

alias tree='exa --tree'
