color_red='\e[0;31'
color_green='\e[0;32m'
color_blue='\e[0;34'
color_purple='\e[0;35'
color_cyan='\e[0;36'
end_color='\e[m'

export PS1="[${color_cyan}\u${end_color}@${color_cyan}\h${end_color}\] ${color_green}\w${end_color}\n${color_green}\$${end_color} "
