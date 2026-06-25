# my_kphoen.zsh-theme — standalone, no oh-my-zsh dependency

autoload -U colors && colors
setopt prompt_subst prompt_percent

# ── helpers ──────────────────────────────────────────────

prompt_end() {
	[[ $EUID -ne 0 ]] && echo '❯' || echo '#'
}

git_branch() {
	local ref
	ref=$(git symbolic-ref --short HEAD 2>/dev/null) || ref=$(git rev-parse --short HEAD 2>/dev/null) || return
	echo " on ${ref}"
}

# ── colors ───────────────────────────────────────────────

user_color="%{$fg[red]%}"
host_color="%{$fg[magenta]%}"
path_color="%{$fg[blue]%}"
git_color="%{$fg[green]%}"
lvl_color="%{$fg[yellow]%}"
err_color="%{$fg[red]%}"
reset="%{$reset_color%}"

# ── prompt parts (static formatting) ─────────────────────

start_bracket="["
end_bracket="]"
at_sign="@"
colon=":"
newline=$'\n'

# These use single quotes / escaping so they re-evaluate at prompt time:
#   %n, %m, %~ are zsh prompt expansions
#   $(git_branch) runs on every prompt render

if [[ "$TERM" != "dumb" ]] && [[ "$DISABLE_LS_COLORS" != "true" ]]; then
	PROMPT="${start_bracket}${user_color}%n${reset}${at_sign}${host_color}%m${reset}${colon}${lvl_color}\$SHLVL${reset}${colon}${path_color}%~${reset}${git_color}\$(git_branch)${reset}${end_bracket}
%(?..${err_color}%? ↵${reset})\$(prompt_end) "
else
	PROMPT="${start_bracket}%n${at_sign}%m${colon}\$SHLVL${colon}%~\$(git_branch)${end_bracket}
%(?..%? ↵)\$(prompt_end) "
fi

RPROMPT=''
