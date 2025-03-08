#!/bin/bash

PROFILE_NAME="Zellij"
PROFILE_SLUG=$(uuidgen)

dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/visible-name "'$PROFILE_NAME'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/use-system-font false
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/font "'JetBrainsMono NF 16'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/background-transparency-percent 20
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/use-transparent-background true
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/cursor-shape "'ibeam'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/cursor-blink-mode "'on'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/scrollback-lines 50000
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/use-custom-command false

dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_SLUG/background-transparency-percent 20

EXISTING_PROFILES=$(dconf read /org/gnome/terminal/legacy/profiles:/list)

if [[ -z $EXISTING_PROFILES || "$EXISTING_PROFILES" == "@as []" ]]; then
  dconf write /org/gnome/terminal/legacy/profiles:/list "['$PROFILE_SLUG']"
else
  NEW_PROFILES_LIST=$(echo $EXISTING_PROFILES | sed "s/]$/, '$PROFILE_SLUG']/")
  dconf write /org/gnome/terminal/legacy/profiles:/list "$NEW_PROFILES_LIST"
fi

dconf write /org/gnome/terminal/legacy/profiles:/default "'$PROFILE_SLUG'"

mkdir -p ~/.config/gtk-3.0/
echo "VteTerminal, vte-terminal { padding: 20px; }" >>~/.config/gtk-3.0/gtk.css

echo "✅ Profile '$PROFILE_NAME' successfully configured!"
