#!/usr/bin/env sh

mode='SYMLINK'
thing=''

# Check args for mode
while getops 'c' option; do
	case "$option" in
		c)
			mode="COPY"
			;;
	esac
done
shift $((OPTIND - 1))

arg_iter=0
for arg in "$@"; do
	arg_iter=$(expr $arg_iter + 1)
	if [[ "$arg" == '--copy' ]]; then
		mode='COPY'
		arg_iter=0
		break
	fi
done

if [[ "$DOT" == '' ]]; then
	echo 'Error: cannot stow anything until $DOT is set to DOTFILES location'
	exit 1
elif [[ "$HOME" == '' ]]; then
	echo 'Error: cannot stow anything until $HOME is set'
	exit 1
fi

if [[ "$arg_iter" == '0' ]]; then
	thing="$1"
else
	# assume
	thing="$2"
fi

thing_in() {
	thing="$1"
	arr="$2"
	for name in "${arr[@]}"; do
		if [[ "$thing" == "$name" ]]; then
			return 1
		fi
	done
	return 0
}

stow_it() {
	src="$1"
	dest="$2"
	if [[ "$mode" == 'COPY' ]]; then
		# -v verbose, -R restow(overwrite sym), -t dest dir
		stow -v -R -t "${HOME}/${dest}" "${DOT}/${src}"
	else
		cp -r "${DOT}/${src}" "${HOME}/${dest}"
	fi
}

if [[ $(thing_in "$thing" ('neovim' 'nvim' 'nv')) ]]; then
	stow_it 'config/nvim' '.config/'

elif [[ "$thing" == 'alacritty' ]]; then
	stow_it 'config/alacritty' '.config/'

elif [[ "$thing" == 'tmux' ]]; then
	stow_it 'config/tmux' '.config/'

fi

