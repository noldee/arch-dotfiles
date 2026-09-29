#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# ─────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────

alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias grep='grep --color=auto'
alias fm='yazi'


# ─────────────────────────────────────────────
# Pywal colors
# ─────────────────────────────────────────────
#
# Load the current Pywal colors when a new
# terminal/shell starts.
#
# This keeps new footclient windows synchronized
# with the current wallpaper.
# ─────────────────────────────────────────────

if [[ -f "$HOME/.cache/wal/sequences" ]]; then
    cat "$HOME/.cache/wal/sequences"
fi


# ─────────────────────────────────────────────
# Node.js version manager
# ─────────────────────────────────────────────

eval "$(fnm env --use-on-cd)"


# ─────────────────────────────────────────────
# Random Fastfetch logo
# ─────────────────────────────────────────────

fastfetch() {
    local logo_dir="$HOME/Pictures/fastfetch-logos"
    local logo=""

    if [[ -d "$logo_dir" ]]; then
        logo=$(
            find "$logo_dir" \
                -maxdepth 1 \
                -type f \
                -iname "*.png" \
                2>/dev/null |
            shuf -n 1
        )
    fi

    if [[ -n "$logo" ]]; then
        command fastfetch \
            --logo "$logo" \
            --logo-type sixel \
            "$@"
    else
        command fastfetch "$@"
    fi
}


# ─────────────────────────────────────────────
# Starship prompt
# ─────────────────────────────────────────────

eval "$(starship init bash)"
