#!/usr/bin/env bash

set -euo pipefail

ROOT="${1:-.}"

EXCLUDES=(
    ".git"
    ".svn"
    ".hg"
    "node_modules"
    ".venv"
    "venv"
    "__pycache__"
    ".idea"
    ".vscode"
    "dist"
    "build"
    "target"
    "test.txt"
)

should_exclude() {
    local path="$1"

    for exclude in "${EXCLUDES[@]}"; do
        [[ "$path" == *"/$exclude"* ]] && return 0
        [[ "$(basename "$path")" == "$exclude" ]] && return 0
    done

    return 1
}

walk() {
    local dir="$1"

    for item in "$dir"/* "$dir"/.*; do
        [[ ! -e "$item" ]] && continue

        local name
        name="$(basename "$item")"

        [[ "$name" == "." || "$name" == ".." ]] && continue

        should_exclude "$item" && continue

        if [[ -d "$item" ]]; then
            echo
            echo "===== DIRECTORY: ${item#./} ====="
            walk "$item"
        elif [[ -f "$item" ]]; then
            echo
            echo "===== FILE: ${item#./} ====="
            cat "$item"
        fi
    done
}

walk "$ROOT"
