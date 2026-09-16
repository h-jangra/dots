export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.npm-global/bin:$PATH"

HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:erasedups
shopt -s autocd cdspell checkwinsize histappend

alias ls='eza --icons=auto'
alias ll='eza -lh --icons=auto --git'
alias la='eza -lah --icons=auto --git'

git_repo_if() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    printf '%s%s' "$(git branch --show-current)" "$(git status --porcelain | grep -q . && echo '*')"
}

PS1='\[\e[38;5;110m\]\w\[\e[0m\] \[\e[38;5;60m\]$(git_repo_if)\[\e[0m\]\n\[\e[38;5;139m\]❯\[\e[0m\] '

if command -v fzf >/dev/null 2>&1; then
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

eval "$(zoxide init bash)"

[[ $PS1 && ! ${BASH_COMPLETION_VERSINFO:-} &&
  -f /usr/share/bash-completion/bash_completion ]] &&
    . /usr/share/bash-completion/bash_completion

# source "/usr/share/ghost/ghost.sh"
