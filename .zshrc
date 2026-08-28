export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

autoload -Uz colors vcs_info
colors

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%F{5} %b%f'

git_prompt() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  printf '%s%s' "$(git branch --show-current)" "$(git status --porcelain | grep -q . && echo '*')"
}

precmd() { git_prompt >/dev/null }

PROMPT='%F{#88c0d0}%~%f %F{#4c566a}$(git_prompt)%f
%F{#b48ead}❯%f '

setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PROMPT_SUBST

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

autoload -U select-word-style
select-word-style bash

bindkey '\e[127;5u' backward-kill-word
bindkey '\e[3;5~' kill-word

bindkey -e
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'

if command -v fzf >/dev/null 2>&1; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

eval "$(zoxide init zsh)"

if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

extract () {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.7z)      7z x "$1" ;;
      *) echo "Cannot extract '$1'" ;;
    esac
  fi
}

export PATH=$HOME/.npm-global/bin:$PATH

export PGDATA=$HOME/.pg_dir
export BROWSER=zen-browser
