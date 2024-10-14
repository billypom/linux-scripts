#!/bin/sh
# No argument = normal keyboard
# With argument = macbook keyboard
if [ $# -eq 0 ]; then
    gsettings set org.gnome.desktop.input-sources xkb-options "[]"
    echo "Normal keyboard mode"
else
    gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:swap_lwin_lctl']"
    echo "Macbook keyboard mode"
fi

