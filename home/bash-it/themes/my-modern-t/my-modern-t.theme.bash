# The "modern-t" theme is a "modern" theme variant with support
# for "t", the minimalist python todo list utility by Steve Losh.
# Get and install "t" at https://github.com/sjl/t#installing-t
#
# Warning: The Bash-it plugin "todo.plugin" breaks the "t"
# prompt integration, please disable it while using this theme.

SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_GIT_CHAR="${bold_green}±${normal}"
SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"

case $TERM in
	xterm*|tmux*)
	TITLEBAR="\[\033]0;\w\007\]"
	;;
	*)
	TITLEBAR=""
	;;
esac

if [ "$EUID" -ne 0 ]; then
	PROMPT_END='❯'
else
	PROMPT_END='#'
fi


PS3=">> "

is_vim_shell() {
	if [ ! -z "$VIMRUNTIME" ]
	then
		echo "[${cyan}vim shell${normal}]"
	fi
}

prompt() {
	SCM_PROMPT_FORMAT='[%s][%s]'
	if [ $? -ne 0 ]
	then
		# Yes, the indenting on these is weird, but it has to be like
		# this otherwise it won't display properly.

		PS1="${TITLEBAR}${bold_red}┌─[${cyan}$(t 2>/dev/null || echo -n '' | wc -l | sed -e's/ *//')${reset_color}]${reset_color}[${green}$SHLVL${reset_color}]$(scm_prompt)[${cyan}$(short_pwd 2>/dev/null || echo -n '\W')${normal}]$(is_vim_shell)
		${bold_red}└─▪${PROMPT_END} ${normal} "
	else
		PS1="${TITLEBAR}┌─[${cyan}$(t 2>/dev/null || echo -n '' | wc -l | sed -e's/ *//')${reset_color}][${green}$SHLVL${reset_color}]$(scm_prompt)[${cyan}$(short_pwd 2>/dev/null || echo -n '\W')${normal}]$(is_vim_shell)
└─▪${bold_green}${PROMPT_END} ${normal}"
	fi
}

PS2="└─▪ "



safe_append_prompt_command prompt
