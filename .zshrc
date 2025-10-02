export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    docker
    docker-compose
    aws
    python
    node
    npm
)

source $ZSH/oh-my-zsh.sh

aws_region_prompt() {
    local region=$(aws configure get region 2>/dev/null)
    if [ -n "$region" ]; then
        echo "%{$fg[cyan]%}<$region>%{$reset_color%}"
    fi
}

PROMPT='%(?:%{$fg_bold[green]%}aws-cli-env ➜ :%{$fg_bold[red]%}aws-cli-env ➜ )%{$fg[cyan]%}~ %{$reset_color%}$(git_prompt_info)$(aws_region_prompt)'

export EDITOR='nvim'
export VISUAL='nvim'

export PATH=$HOME/bin:/usr/local/bin:$PATH

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

alias vim='nvim'
alias vi='nvim'

alias python='python3'
alias pip='pip3'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'

alias awswho='aws sts get-caller-identity'
alias awsregion='aws configure get region'

alias t='tmux'
alias ta='tmux attach'
alias tn='tmux new -s'
alias tl='tmux ls'

export AWS_PAGER=""

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

autoload -Uz compinit
compinit

if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

echo "🚀 AI Practitioner Environment Ready!"
