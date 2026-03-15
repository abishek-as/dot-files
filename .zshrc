# ==============================================================================
# 1. CORE ZSH CONFIGURATION
# ==============================================================================
# Path to oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Fix for insecure directories warning
ZSH_DISABLE_COMPFIX=true

# History Settings (Optimized for heavily used terminals)
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY       # Append to history file rather than replace
setopt HIST_IGNORE_DUPS     # Do not record an event that was just recorded again
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS    # Do not display a line previously found
setopt SHARE_HISTORY        # Share history between all sessions

# Enable command auto-correction (Set to "false" if it annoys you)
ENABLE_CORRECTION="true"

# ==============================================================================
# 2. THEME & PLUGINS
# ==============================================================================
ZSH_THEME="agnoster"

# Plugins List
# Note: Ensure zsh-autosuggestions & zsh-syntax-highlighting are installed in custom/plugins
plugins=(
    sudo
    k
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Autosuggestions Config (Grey text for suggestions)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

# ==============================================================================
# 3. ENVIRONMENT & PATHS
# ==============================================================================

# Local Binaries
export PATH=$PATH:$HOME/.local/bin

# Java & Maven
export JAVA_HOME="/usr/lib/jvm/java-25-openjdk-amd64"
export MAVEN_HOME="/opt/maven/bin"
export PATH=$PATH:$JAVA_HOME:$MAVEN_HOME

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# ==============================================================================
# 4. ALIASES
# ==============================================================================

# --- System & Safety ---
alias s="sudo"
alias c="clear"
alias q="exit"
alias rm="rm -i" # Ask before deleting
alias cp="cp -i" # Ask before overwriting
alias mv="mv -i" # Ask before overwriting

# --- Package Management ---
# Auto-detects apt vs nala for smoother experience
alias sai="sudo apt install"
alias sni="sudo nala install"
alias up="sudo apt -y update ; sudo apt dist-upgrade -y ; sudo apt -y full-upgrade ; sudo apt -y autoremove ; sudo snap refresh ; sudo flatpak update -y ;"
alias up2="sudo nala update ; sudo nala upgrade -y ; sudo nala autoremove -y ; sudo snap refresh ; sudo flatpak update -y ;"

# --- Editors ---
alias v="nvim"
alias ge="gnome-text-editor"
alias n="nano"
alias co="code"
alias zconfig="nano ~/.zshrc"
alias sourcez="source ~/.zshrc"

# --- Git Shortcuts (Productivity Boost) ---
alias g="git"
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"

# --- Navigation & Listing (Eza Enhanced) ---
# Note: The 'echo' ensures a clean separation from previous output
alias cat="batcat"
alias ls="echo ; eza --icons -aG --group-directories-first"
alias ll="echo ; eza --icons -algh --group-directories-first"
alias lt="echo ; eza --icons -alhT --group-directories-first"
alias ..="cd .."
alias ...="cd ../.."

# --- Global Config Shortcuts ---
alias -g z=~/.zshrc
alias -g b=~/.bashrc
alias -g kc=~/.config/kitty/kitty.conf
alias -g spc=~/.config/starship.toml

# ==============================================================================
# 5. FUNCTIONS
# ==============================================================================

# C Compiler (Run & Delete) - Basic
g1() {
    gcc "$1" -o "${1%.*}" && ./"${1%.*}" && rm "${1%.*}"
}

# C Compiler (Run & Delete) - Optimized/Strict
g2() {
    gcc -std=c17 -O2 -Wall "$1" -o "${1%.*}" && ./"${1%.*}" && rm "${1%.*}"
}

# Java Compiler (Run & Delete)
jc() {
    javac "$1" && java "${1%.*}" && rm "${1%.*}.class"
}

# Python Quick-Run
p3() { python3 "$1"; }

# Make Directory & Enter it immediately
mkcd() { mkdir -p "$1" && cd "$1"; }

# Universal Extractor
# Usage: extract <file>
extract() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar e $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ==============================================================================
# 6. UI & PROMPT CUSTOMIZATION
# ==============================================================================

# Show system specs on launch
fastfetch

# ---------------------------------------------------
# Custom Agnoster Logic
# Features: 2-Line Prompt, Smart Timer, Language Detection, Right-Side Clock
# ---------------------------------------------------

# Disable default venv prompt mechanisms (we handle this manually)
export VIRTUAL_ENV_DISABLE_PROMPT=1

# --- Language Detectors ---

prompt_my_python() {
    # Trigger if: VIRTUAL_ENV is active OR standard python files are found
    if [[ -n "$VIRTUAL_ENV" ]] || [[ -f requirements.txt || -f pyproject.toml || -f Pipfile || -n $(find . -maxdepth 1 -name "*.py" 2>/dev/null) ]]; then

        # Get Python Version
        local ver=$(python3 --version 2>/dev/null | awk '{print $2}')
        [[ -z "$ver" ]] && ver=$(python --version 2>/dev/null | awk '{print $2}')

        # Colors: 82 = Bright Green, Black text
        local bg_color=82
        local fg_color=black

        # If Venv active -> "3.12 (.venv)", else -> "3.12"
        if [[ -n "$VIRTUAL_ENV" ]]; then
            local venv_name="${VIRTUAL_ENV##*/}"
            [[ -n "$ver" ]] && prompt_segment $bg_color $fg_color " $ver ($venv_name)"
        else
            [[ -n "$ver" ]] && prompt_segment $bg_color $fg_color " $ver"
        fi
    fi
}

prompt_my_bun() {
    # Detect Bun: look for bun.lockb or bun.lock
    if [[ -f bun.lockb || -f bun.lock ]]; then
        local ver=$(bun --version 2>/dev/null)
        # Color 208 = Orange
        [[ -n "$ver" ]] && prompt_segment 208 black " $ver"
    fi
}

prompt_my_node() {
    # Only show Node if Bun isn't already taking the spotlight (optional preference)
    # or standard detection
    if [[ -f package.json || -d node_modules ]]; then
        local ver=$(node -v 2>/dev/null)
        # Color 118 = Standard Bright Neon Green
        [[ -n "$ver" ]] && prompt_segment 118 black "󰎙 $ver"
    fi
}

prompt_my_dotnet() {
    if [[ -n $(find . -maxdepth 1 -name "*.csproj" -o -name "*.fsproj" -o -name "*.sln" 2>/dev/null) ]]; then
        local ver=$(dotnet --version 2>/dev/null)
        # Color 129 = Purple
        [[ -n "$ver" ]] && prompt_segment 129 black ".NET $ver"
    fi
}

prompt_my_java() {
    if [[ -f pom.xml || -f build.gradle || -n $(find . -maxdepth 1 -name "*.java" 2>/dev/null) ]]; then
        local ver=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1,2)
        # Color 160 = Red
        [[ -n "$ver" ]] && prompt_segment 9 black "󰅶 $ver"
    fi
}

# --- Timer & Right Prompt Logic ---

preexec() {
    cmd_start=$SECONDS
}

precmd() {
    # Add a visual break (newline) before the prompt starts
    # Using 'print -P' handles prompt expansion safely
    print -P ""

    # Calculate Duration
    if [ -n "$cmd_start" ]; then
        local now=$SECONDS
        local duration=$((now - cmd_start))
        unset cmd_start
    else
        local duration=0
    fi

    # Prepare Timer String (Human Readable)
    local formatted_time=""
    if [ "$duration" -ge 2 ]; then
        local hours=$((duration / 3600))
        local minutes=$(((duration % 3600) / 60))
        local seconds=$((duration % 60))

        if ((hours > 0)); then
            formatted_time="${hours}h ${minutes}m"
        elif ((minutes > 0)); then
            formatted_time="${minutes}m ${seconds}s"
        else
            formatted_time="${seconds}s"
        fi
    fi

    # --- RPROMPT Construction ---
    # Time Format: Tue 20 Jan 05:00 PM
    local clock_time="%D{%a %d %b %I:%M %p}"

    if [ -n "$formatted_time" ]; then
        # CASE 1: Timer Active -> [Timer] -> [Clock]
        RPROMPT="%F{220}%K{220}%F{black} ${formatted_time} %F{250}%K{250}%F{black} ${clock_time} %f%k"
    else
        # CASE 2: No Timer -> [Clock] only
        RPROMPT="%F{250}%K{250}%F{black} ${clock_time} %f%k"
    fi
}

# --- Main Prompt Builder ---

build_prompt() {
    RETVAL=$?

    # 1. Status Indicator (Check/Cross)
    prompt_status

    # 2. Custom Language Detectors
    prompt_my_python
    prompt_my_bun
    prompt_my_node
    prompt_my_dotnet
    prompt_my_java

    # 3. Standard Context
    prompt_aws
    prompt_context
    prompt_dir
    prompt_git
    prompt_bzr
    prompt_hg

    prompt_end

    # --- Line 2 Setup ---
    echo ""
    # Manual "Blue Box" Prompt
    echo -n "%K{blue}%F{black} ~ %k%F{blue}%f"
}
