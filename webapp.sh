#!/usr/bin/env bash

APP_DIR="$HOME/.local/share/applications"
BROWSER="helium-browser"

case "$1" in
  add)
    url="$2"

    if [[ -z "$url" ]]; then
      read -rp "URL: " url
    fi

    [[ "$url" =~ ^https?:// ]] || url="https://$url"

    domain="${url#*://}"
    domain="${domain%%/*}"
    domain="${domain#www.}"

    name="${domain%%.*}"
    name="${name^}"

    id="webapp-${domain//./-}"
    file="$APP_DIR/$id.desktop"

    mkdir -p "$APP_DIR"

    cat > "$file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Exec=$BROWSER --app=$url
Icon=$BROWSER
Terminal=false
Categories=Network;
EOF

    update-desktop-database "$APP_DIR"
    echo "Added $name"
    ;;

  list)
    found=false

    for file in "$APP_DIR"/webapp-*.desktop; do
      [[ -e "$file" ]] || continue
      found=true

      id=$(basename "$file" .desktop)
      name=$(grep '^Name=' "$file" | cut -d= -f2-)
      url=$(grep '^Exec=' "$file" | sed -n 's/.*--app=//p')

      echo "$name - $url"
    done

    $found || echo "No web apps found"
    ;;

  open)
    query="$2"

    if [[ -z "$query" ]]; then
      echo "Usage: $0 open <name>"
      exit 1
    fi

    found=false

    for file in "$APP_DIR"/webapp-*.desktop; do
      [[ -e "$file" ]] || continue

      id=$(basename "$file" .desktop)
      name=$(grep '^Name=' "$file" | cut -d= -f2-)

      if [[ "${name,,}" == "${query,,}" || "${id,,}" == *"${query,,}"* ]]; then
        gtk-launch "$id"
        found=true
        break
      fi
    done

    $found || echo "Web app '$query' not found"
    ;;

  remove|rm)
    name="$2"

    if [[ -z "$name" ]]; then
      echo "Usage: $0 remove <name>"
      exit 1
    fi

    found=false

    for file in "$APP_DIR"/webapp-*.desktop; do
      [[ -e "$file" ]] || continue

      app_name=$(grep '^Name=' "$file" | cut -d= -f2-)

      if [[ "${app_name,,}" == "${name,,}" ]]; then
        rm "$file"
        found=true
        echo "Removed $app_name"
        break
      fi
    done

    update-desktop-database "$APP_DIR"

    $found || echo "Web app '$name' not found"
    ;;

  *)
    echo "Usage:"
    echo "  $0 add [url]"
    echo "  $0 list"
    echo "  $0 open <name>"
    echo "  $0 remove <name>"
    ;;
esac
