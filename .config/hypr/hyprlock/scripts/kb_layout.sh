#!/bin/bash

keyboard=$(hyprctl devices -j | jq '
.keyboards
| ( map(select(.main == true)) | .[0] )
  // ( map(select(.active_keymap != null)) | .[0] )
  // .[0]
')

[ -z "$keyboard" ] && exit 0

# get layout name
if echo "$keyboard" | jq -e '.keymap_names' >/dev/null 2>&1; then
    active=$(echo "$keyboard" | jq -r '.active_layout // 0')
    mapfile -t layouts <<< "$(echo "$keyboard" | jq -r '.keymap_names[]')"
    layout="${layouts[$active]}"
else
    layout=$(echo "$keyboard" | jq -r '.active_keymap // ""')
fi

# take first two letters, uppercase → EN / AR automatically
result="${layout:0:2}"
[ -z "$result" ] && exit 0  # safety check
echo "$result" | tr '[:lower:]' '[:upper:]'