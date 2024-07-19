if [ -e "$HOME/.cargo/env" ]; then
	source "$HOME/.cargo/env"
fi

if [ -e "$HOME/.SECRETS" ]; then
	source "$HOME/.SECRETS"
fi

if [ -e "$HOME/.profile-prefs" ]; then
	source "$HOME/.profile-prefs"
fi

export PATH="$PATH:$HOME/.local/bin:$HOME/.turso"
export DOT="$HOME/dotfiles"

export BAT_STYLE='header-filename,numbers,changes,grid'
export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=header-filename,numbers,changes {}' --bind '?:toggle-preview,ctrl-u:preview-up,ctrl-d:preview-down' --preview-window hidden:up:20"

alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias exl='exa -l'
alias exaa='exa -a'
alias exla='exa -la'
alias exg='exa --group-directories-first'
alias exgl='exa -l --group-directories-first'
alias exga='exa -a --group-directories-first'
alias exgla='exa -la ---group-directories-first'
alias cls='clear'

alias lsbin='compgen -c'

alias nv='nvim'
alias nvb='NVIM_CONFIG_MODE=BASIC nvim'
alias nvl='NVIM_CONFIG_MODE=LITE nvim'
alias nvf='NVIM_CONFIG_MODE=FULL nvim'

alias rga='rg --hidden'

alias find_all='fd -HI --follow'
alias native_find_all='find . -follow'
alias find_dir='OUT=$(fd --type d | fzf)'
alias find_dir_all='OUT=$(find_all --type d | fzf)'
alias native_find_dir='OUT=$(find . -type d | fzf)'
alias native_find_dir_all='OUT=$(native_find_all -type d | fzf)'

alias fcd='find_dir && cd $OUT'
alias fcda='find_dir_all && cd $OUT'
alias sfcd='native_find_dir && cd $OUT'
alias sfcda='native_find_dir_all && cd $OUT'

alias fnv='OUT=$(fzf) && nvim $OUT'
alias fnva='OUT=$(native_find_all) && nvim $OUT'
alias fnvb='NVIM_CONFIG_MODE=BASIC fnv'
alias fnvl='NVIM_CONFIG_MODE=LITE fnv'
alias fnvf='NVIM_CONFIG_MODE=FULL fnv'
# having trouble with `fd --folow` so using stock find
alias fza='find -L -H | fzf'
alias fnva='OUT=$(find -L -H | fzf) && echo $OUT | xargs nvim'
alias fcda='OUT=$(find -L -H -type d | fzf) && echo $out | nvim'

alias nixdev='nix develop --shell $(echo $SHELL | xargs basename)'

short_pwd() {
	local pwd=$(pwd)
	local shortened_pwd=""
	local home_prefix="$HOME"

	if [[ $pwd == "/" ]]; then
		shortened_pwd="/"
	elif [[ $pwd == $home_prefix* ]]; then
		shortened_pwd="~"
		pwd=${pwd#$home_prefix}
	fi

	IFS='/' read -ra dirs <<< "$pwd"
	local last_index=$((${#dirs[@]} - 1))

	for i in "${!dirs[@]}"; do
		if [ -z "${dirs[$i]}" ]; then
			continue
		fi

		if [ "$i" -eq "$last_index" ]; then
			shortened_pwd+="/${dirs[$i]}"
		elif [ "${dirs[$i]:0:1}" == "." ]; then
			shortened_pwd+="/${dirs[$i]:0:2}"
		elif [ "${#dirs[$i]}" -ge 1 ]; then
			shortened_pwd+="/${dirs[$i]:0:1}"
		else
			shortened_pwd+="/${dirs[$i]}"
		fi
	done

	echo -n $shortened_pwd
}

