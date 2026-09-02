#!/usr/bin/env bash

command -v yay >/dev/null || {
    echo "Error: yay not found."
    exit 1
}

list_repo() {
    pacman -Slq
}

list_installed() {
    pacman -Qi |
    awk '
        /^Name/ {
            name = $3
        }
        /^Installed Size/ {
            size = $4
            unit = $5

            mult = 1
            if (unit == "KiB") mult = 1024
            if (unit == "MiB") mult = 1024^2
            if (unit == "GiB") mult = 1024^3

            bytes = size * mult
            printf "%020.0f\t[✓] %8.1f %-3s %s\n", bytes, size, unit, name
        }
    ' |
    sort -rn |
    cut -f2-
}

preview() {
    local pkg="${1##* }"
    pacman -Qi "$pkg" 2>/dev/null ||
        yay -Si "$pkg" 2>/dev/null
}

export -f preview list_repo list_installed

selected="$(
    list_repo |
    fzf \
        --multi \
        --layout=reverse \
        --height=100% \
        --border \
        --preview='bash -c "preview {}"' \
        --preview-window='right:55%:wrap' \
        --bind='alt-p:toggle-preview' \
        --bind='alt-i:reload(bash -c list_installed)+change-prompt(Installed> )' \
        --bind='alt-a:reload(bash -c list_repo)+change-prompt(Package> )' \
        --bind='tab:toggle+down' \
        --bind='btab:toggle+up' \
        --color='pointer:green,marker:green' \
        --header='TAB select • ENTER install/remove • ALT-I installed • ALT-A packages • ALT-P preview' \
        --prompt='Package> '
)"

(( $? == 0 )) || exit 130
[[ -z "$selected" ]] && exit 0

mapfile -t pkgs < <(
    awk '{print $NF}' <<< "$selected"
)

install=()
remove=()

for pkg in "${pkgs[@]}"; do
    if pacman -Q "$pkg" &>/dev/null; then
        remove+=("$pkg")
    else
        install+=("$pkg")
    fi
done

if ((${#install[@]})); then
    yay -S "${install[@]}"
fi

if ((${#remove[@]})); then
    yay -Rns "${remove[@]}"
fi

command -v updatedb >/dev/null &&
    sudo updatedb >/dev/null 2>&1 &

