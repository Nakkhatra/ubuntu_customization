#!/bin/bash

# This script is used to get all the current settings of dash to dock extension to write the values using dconf later
# Define the base path
BASE_PATH="/org/gnome/shell/extensions/dash-to-dock/"

# List all keys under the base path
KEYS=$(dconf list $BASE_PATH)

# Iterate over each key and read its value
for key in $KEYS; do
    FULL_PATH="${BASE_PATH}${key}"
    echo -n "$FULL_PATH: "
    dconf read $FULL_PATH
done
