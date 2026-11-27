#!/usr/bin/env bash

set -uo pipefail

LOCK="${XDG_RUNTIME_DIR:-/tmp}/pkg-installer.lock"
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/pkg-installer.pid"

failed=0

finish() {
    local status=$?
    if (( failed || status != 0 )); then
        printf '\n'
        read -r -n 1 -s -p 'Operation failed. Press any key to close...' </dev/tty
        printf '\n'
    fi
}

exec 9>"$LOCK"

if ! flock -n 9; then
    if [[ -f "$PIDFILE" ]]; then
        pid=$(<"$PIDFILE")
        if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
            kill -TERM "$pid" 2>/dev/null || true
        fi
    fi
    exit 0
fi

echo "$$" > "$PIDFILE"
trap 'rm -f "$PIDFILE"; finish' EXIT

for cmd in yay pacman fzf awk sort cut flock; do
    command -v "$cmd" >/dev/null 2>&1 || {
        printf 'Error: %s not found.\n' "$cmd"
        failed=1
        exit 1
    }
done

declare -A installed

load_installed() {
    installed=()
    while IFS= read -r pkg; do
        installed["$pkg"]=1
    done < <(pacman -Qq)
}

load_installed

printf 'Loading package list (first run may take a while)...\n' >&2
PACKAGE_LIST=$(yay -P --complete) || {
    printf 'Error: Failed to retrieve package list.\n'
    failed=1
    exit 1
}

repo_list=()

while IFS=$'\t' read -r pkg _; do
    [[ -z "$pkg" ]] && continue
    repo_list+=("$pkg")
done <<< "$PACKAGE_LIST"

list_repo() {
    printf '%s\n' "${repo_list[@]}"
}

list_installed() {
    pacman -Qi |
    awk '
        /^Name/ { name=$3 }
        /^Installed Size/ {
            size=$4
            unit=$5
            mult=1
            if (unit=="KiB") mult=1024
            if (unit=="MiB") mult=1048576
            if (unit=="GiB") mult=1073741824
            printf "%020.0f\t[✓] %8.1f %-3s %s\n", size*mult, size, unit, name
        }
    ' | sort -rn | cut -f2-
}

preview() {
    local pkg="${1##* }"
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/yami/pkg-preview"
    local cache_file="$cache_dir/$pkg"

    if [[ -f "$cache_file" ]]; then
        cat "$cache_file"
        return
    fi

    mkdir -p "$cache_dir" 2>/dev/null
    {
        pacman -Qi "$pkg" 2>/dev/null && exit 0
        pacman -Si "$pkg" 2>/dev/null && exit 0
        printf 'Name             : %s\nSource           : AUR\n\n' "$pkg"
        yay -Si "$pkg" 2>/dev/null ||
            printf 'AUR metadata unavailable: %s\n' "$pkg"
    } | tee "$cache_file"
}

export -f preview list_repo list_installed

selected=$(
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
) || exit 0

[[ -z "$selected" ]] && exit 0

mapfile -t pkgs < <(awk '{print $NF}' <<< "$selected" | sort -u)

install=()
remove=()

for pkg in "${pkgs[@]}"; do
    if [[ ${installed[$pkg]+x} ]]; then
        remove+=("$pkg")
    else
        install+=("$pkg")
    fi
done

printf '\nSelected packages:\n'

if ((${#install[@]})); then
    printf '\nInstall:\n'
    printf '  + %s\n' "${install[@]}"
fi

if ((${#remove[@]})); then
    printf '\nRemove:\n'
    printf '  - %s\n' "${remove[@]}"
fi

printf '\n'

if ((${#install[@]})); then
    printf '%s\n' '--- Installing ---'
    if ! yay -S "${install[@]}"; then
        failed=1
        exit 1
    fi
fi

if ((${#remove[@]})); then
    printf '\n%s\n' '--- Removing ---'
    if ! yay -Rns "${remove[@]}"; then
        failed=1
        exit 1
    fi
fi

if ((${#install[@]} || ${#remove[@])) && command -v updatedb >/dev/null 2>&1; then
    sudo updatedb >/dev/null 2>&1 </dev/null &
fi

exit 0
