. "$HOME/.cargo/env"

source "$HOME/.SECRETS"

export PATH="$PATH:$HOME/bin/"

export EDITOR='nvim'
export SUDO_EDITOR='env NVIM_MODE="BASIC" nvim'
export VISUAL='nvim'

export NVIM_CONFIG_MODE='FULL'

export BAT_STYLE='header-filename,numbers,rule,changes,grid'
export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=header-filename,numbers,changes {}' --bind '?:toggle-preview,ctrl-u:preview-up,ctrl-d:preview-down' --preview-window hidden:up:20"

alias ls='ls --color=always'
alias ll='ls -lh --color=always'
alias la='ls -lah --color=always'
alias cls='clear'

alias lsbin='compgen -c'

alias nv='nvim'

alias fzf="fzf --bind='F2:toggle-preview'"

alias rga='rg --hidden'

