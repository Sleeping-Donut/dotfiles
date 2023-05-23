# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

alias nv=nvim
alias sedown="sudo setenforce Permissive"
alias seup="sudo setenforce Enforcing"
alias sestatus="getenforce"

export EDITOR=vim
export DMENU_OPTIONS="-b"

export PATH=$PATH:~/bin/
