
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_GIT_CHAR="${bold_green}±${normal}"
SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"
SCM_GIT_UNTRACKED_CHAR="?:"
SCM_GIT_UNSTAGED_CHAR="U:"
SCM_GIT_STAGED_CHAR="S:"

case $TERM in
	xterm*|tmux*)
	TITLEBAR="\[\033]0;\w\007\]"
	;;
	*)
	TITLEBAR=""
	;;
esac

prompt_end() {
	if [ "$EUID" -ne 0 ]; then
		echo '❯'
	else
		echo '#'
	fi
}


PS3=">> "

is_vim_shell() {
	if [ ! -z "$VIMRUNTIME" ]
	then
		echo "[${cyan}vim shell${normal}]"
	fi
}

detect_venv() {
	python_venv=""
	# Detect python venv
	if [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
		python_venv="($PYTHON_VENV_CHAR${CONDA_DEFAULT_ENV}) "
	elif [[ -n "${VIRTUAL_ENV}" ]]; then
		python_venv="($PYTHON_VENV_CHAR$(basename "${VIRTUAL_ENV}")) "
	fi
}

prompt() {
	PREV_EXIT_CODE="$?"

	SCM_PROMPT_FORMAT='(%s %s)'

	SH_LEVEL="${reset_color}[${yellow}${SHLVL}${reset_color}]"
	SH_LEVEL_ERR="${bold_red}[${yellow}${SHLVL}${bold_red}]${reset_color}"
	USER_HOST="${reset_color}[${green}\u${reset_color}@${green}\h${reset_color}]"
	USER_HOST_ERR="${bold_red}[${green}\u${bold_red}@${green}\h${bold_red}]${reset_color}"
	WORKING_DIR="${cyan}\w${normal}"

	detect_venv

	if [ $PREV_EXIT_CODE -ne 0 ]; then
		# Non zero exit code (something went wrong)

		PS1="${TITLEBAR}${bold_red}┌${SH_LEVEL_ERR}${bold_red}:${USER_HOST_ERR} ${WORKING_DIR} $(scm_prompt) ${python_venv}${dir_color} $(is_vim_shell)\n${bold_red}└ $(prompt_end) ${normal}"
	else
		PS1="${TITLEBAR}┌${SH_LEVEL}:${USER_HOST} ${WORKING_DIR} $(scm_prompt) ${python_venv}${dir_color} $(is_vim_shell)\n└${bold_green} $(prompt_end) ${normal}"
	fi
}

PS2="└─▪ "



safe_append_prompt_command prompt
