if [ -e "$HOME/.cargo/env" ]; then
	source "$HOME/.cargo/env"
fi

if [ -e "$HOME/.SECRETS" ]; then
	source "$HOME/.SECRETS"
fi

if [ -e "$HOME/.profile-prefs" ]; then
	source "$HOME/.profile-prefs"
fi

export PATH="$PATH:$HOME/.local/bin"

export BAT_STYLE='header-filename,numbers,changes,grid'
export FZF_DEFAULT_OPTS="--preview 'bat --color=always --style=header-filename,numbers,changes {}' --bind '?:toggle-preview,ctrl-u:preview-up,ctrl-d:preview-down' --preview-window hidden:up:20"

alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias exl='exa -l'
alias exaa='exa -a'
alias exla='exa -la'
alias cls='clear'

alias lsbin='compgen -c'

alias nv='nvim'
alias nvb='NVIM_CONFIG_MODE=BASIC nvim'
alias nvl='NVIM_CONFIG_MODE=LITE nvim'
alias nvf='NVIM_CONFIG_MDOE=FULL nvim'

alias rga='rg --hidden'
alias fcd='out=$(fd --type d | fzf) && echo $out | xargs cd'
alias fnv='out=$(fzf) && echo $out | xargs nvim'
alias fnvf='out=$(fzf) && echo $out | xargs nvf'
alias fnvl='out=$(fzf) && echo $out | xargs nvl'
alias fnvb='out=$(fzf) && echo $out | xargs nvb'
# having trouble with `fd --folow` so using stock find
alias fza='find -L -H | fzf'
alias fnva='out=$(find -L -H | fzf) && echo $out | xargs nvim'
alias fcda='out=$(find -L -H -type d | fzf) && echo $out | nvim'

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

