#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
eval "$(fnm env --use-on-cd)"
eval "$(fnm env --use-on-cd)"

fastfetch() {
    local logo_dir="$HOME/Pictures/fastfetch-logos"
    local logo=""

    if [ -d "$logo_dir" ]; then
        logo=$(find "$logo_dir" -maxdepth 1 -type f -iname "*.png" 2>/dev/null | shuf -n 1)
    fi

    if [ -n "$logo" ]; then
        command fastfetch --logo "$logo" --logo-type kitty-direct "$@"
    else
        command fastfetch "$@"
    fi
}

alias fm='yazi'

eval "$(starship init bash)"

alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
