#!/bin/sh

grim -T "$(hyprctl -j activewindow | jq -r '.stableId')" - | wl-copy
