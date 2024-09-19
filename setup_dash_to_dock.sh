#!/bin/bash

git clone https://github.com/micheleg/dash-to-dock.git
make -C dash-to-dock install

# Update dash-to-dock settings using dconf
# Define the base path
BASE_PATH="/org/gnome/shell/extensions/dash-to-dock/"

# Set values for each key
dconf write ${BASE_PATH}apply-custom-theme false
dconf write ${BASE_PATH}background-color "'#090f25'"
dconf write ${BASE_PATH}background-opacity 0.5
dconf write ${BASE_PATH}click-action "'minimize-or-previews'"
dconf write ${BASE_PATH}custom-background-color true
dconf write ${BASE_PATH}custom-theme-shrink true
dconf write ${BASE_PATH}dash-max-icon-size 42
dconf write ${BASE_PATH}dock-fixed false
dconf write ${BASE_PATH}dock-position "'BOTTOM'"
dconf write ${BASE_PATH}extend-height false
dconf write ${BASE_PATH}force-straight-corner false
dconf write ${BASE_PATH}height-fraction 0.48
dconf write ${BASE_PATH}icon-size-fixed false
dconf write ${BASE_PATH}multi-monitor false
dconf write ${BASE_PATH}preferred-monitor 0
dconf write ${BASE_PATH}running-indicator-style "'DASHES'"
dconf write ${BASE_PATH}scroll-action "'do-nothing'"
dconf write ${BASE_PATH}transparency-mode "'FIXED'"

echo "Dash-to-Dock settings updated."
