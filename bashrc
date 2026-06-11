export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.npm-global/bin:$PATH"

HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:erasedups
shopt -s autocd cdspell checkwinsize histappend

export PGDATA="$HOME/.pg_dir"
export BROWSER=zen-browser

alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'

git_prompt_status() {
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local git_info=""
    local git_status

    git_status=$(git status --porcelain=v2 --branch 2>/dev/null)

    echo "$git_status" | grep -q '^1 ' && git_info+=" \[\e[33m\]●\[\e[0m\]"
    echo "$git_status" | grep -q '^? ' && git_info+=" \[\e[31m\]?\[\e[0m\]"

    local ahead behind

    ahead=$(echo "$git_status" | awk '/^# branch\.ab/ {gsub(/\+/,"",$3); print $3}')
    behind=$(echo "$git_status" | awk '/^# branch\.ab/ {gsub(/-/,"",$4); print $4}')

    [[ -n "$ahead" && "$ahead" != "0" ]] && git_info+=" \[\e[32m\]↑${ahead}\[\e[0m\]"
    [[ -n "$behind" && "$behind" != "0" ]] && git_info+=" \[\e[31m\]↓${behind}\[\e[0m\]"

    echo "$git_info"
}

parse_git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    printf "\[\e[35m\] %s\[\e[0m\]" "$(git branch --show-current)"
}

set_prompt() {
    PS1="\[\e[38;5;111m\]\[\e[0m\]\[\e[38;5;183m\]\[\e[0m\]\[\e[38;5;225m\]\[\e[0m\] \[\e[38;5;117m\] \W\[\e[0m\] \$(parse_git_branch)\$(git_prompt_status) "
}

PROMPT_COMMAND=set_prompt

bind '"\C-p":previous-history'
bind '"\C-n":next-history'
bind '"\e[1;5D":backward-word'
bind '"\e[1;5C":forward-word'
bind '"\C-h":backward-kill-word'

if command -v fzf >/dev/null 2>&1; then
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

eval "$(zoxide init bash)"

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "Cannot extract '$1'" ;;
        esac
    fi
}
