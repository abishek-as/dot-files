# Oh-my-zsh config
ZSH_DISABLE_COMPFIX=true
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
ENABLE_CORRECTION="true"
plugins=(sudo k git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Java Config
# export PATH=$PATH:$HOME/.local/bin
# JAVA_HOME="/usr/lib/jvm/jdk-21-oracle-x64"
# export PATH=$PATH:$JAVA_HOME
# MAVEN_HOME="/opt/maven/bin"
# export PATH=$PATH:$MAVEN_HOME

# custom alias
alias up="sudo apt -y update ; sudo apt dist-upgrade -y ; sudo apt -y full-upgrade ; sudo apt -y autoremove ; sudo snap refresh ; sudo flatpak update -y ;"
alias up2="sudo nala update ; sudo nala upgrade -y ; sudo nala autoremove -y ; sudo snap refresh ; sudo flatpak update -y ;"
alias sai="sudo apt install"
alias sni="sudo nala install"
alias s="sudo"
alias v="nvim"
alias ge="gedit"
alias n="nano"
alias c="clear"
alias q="exit"
alias co="code"
alias -g z=~/.zshrc
alias -g b=~/.bashrc
alias -g svc=~/.SpaceVim.d/init.toml
alias -g kc=~/.config/kitty/kitty.conf
alias -g spc=~/.config/starship.toml
# alias lt="exa -aT --color=always --group-directories-first --icons" # tree listing
# alias la="exa -al --color=always --group-directories-first --icons" # preferred listing
# alias ls="exa -a --color=always --group-directories-first --icons"  # all files and dirs
# alias cat="batcat"
alias ls="echo ; exa --icons -aG --group-directories-first"
alias ll="echo ; exa --icons -algh --group-directories-first"
alias lt="echo ; exa --icons -alhT --group-directories-first"

# custom functions
g1() {
    gcc "$1" -o "${1%.*}" && ./"${1%.*}" && rm "${1%.*}"
}

g2() {
    g++ -std=c++17 -O2 -Wall "$1" -o "${1%.*}" && ./"${1%.*}" && rm "${1%.*}"
}

jc() {
    javac "$1" && java "${1%.*}" && rm "${1%.*}.class"
}

p3() {
    python3 "$1"
}

mkcd() {
    mkdir -p $1
    cd $1
}

# Custom commands

# Adds new line after a command
precmd() { print "" }

# Removes user@hostname
DEFAULT_USER=$USER

# Show only current directory
prompt_dir() {
prompt_segment blue $CURRENT_FG '%c'
# prompt_segment blue $CURRENT_FG '%25<...<%~%<<'
}

# Startup commands

# neofetch
# eval "$(starship init zsh)"

# add extra styling for activated venvs
export VIRTUAL_ENV_DISABLE_PROMPT=1
venv() {
    if [[ -v VIRTUAL_ENV ]]; then
        ARROW_FG="016"
        ARROW_BG="183"
        RIGHT_SIDE="183"
        echo "$(arrow_start) ${VIRTUAL_ENV##*/} %{$FG[$RIGHT_SIDE]%}"
    fi
}

# End the prompt, closing any open segments

# prompt_end() {
#     if [[ -n $CURRENT_BG ]]; then
#         echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
#     else
#         echo -n "%{%k%}"
#     fi
#     echo -n "\n❯%{%f%}"
#     CURRENT_BG=''
# }

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
