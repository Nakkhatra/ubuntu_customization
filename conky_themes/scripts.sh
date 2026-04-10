#!/bin/bash

# Get the directory of the current script
CURRENT_DIR="$(dirname "$(realpath "$0")")"

# Kill any running conky instances
killall conky 2>/dev/null || true
sleep 2s

# --- Detect screen resolution and compute scale factors ---
# Baseline is 1920x1080 (positions are tuned for this resolution)
BASE_W=1920
BASE_H=1080

RESOLUTION=$(xrandr 2>/dev/null | grep '\*' | head -1 | awk '{print $1}')
if [ -n "$RESOLUTION" ]; then
    SCREEN_W=$(echo "$RESOLUTION" | cut -d'x' -f1)
    SCREEN_H=$(echo "$RESOLUTION" | cut -d'x' -f2)
else
    SCREEN_W=$BASE_W
    SCREEN_H=$BASE_H
fi

# Generate a scaled conky config from an original config file
# Usage: generate_scaled_config <source_config> <output_path>
generate_scaled_config() {
    local src="$1"
    local dst="$2"

    # Read gap_x and gap_y from the source
    local orig_gap_x orig_gap_y
    orig_gap_x=$(grep -m1 '^gap_x' "$src" | awk '{print $2}')
    orig_gap_y=$(grep -m1 '^gap_y' "$src" | awk '{print $2}')

    # Scale proportionally (using awk for float math)
    local new_gap_x new_gap_y
    new_gap_x=$(awk "BEGIN {printf \"%d\", $orig_gap_x * $SCREEN_W / $BASE_W}")
    new_gap_y=$(awk "BEGIN {printf \"%d\", $orig_gap_y * $SCREEN_H / $BASE_H}")

    # Copy and replace gap values
    sed -e "s/^gap_x .*/gap_x $new_gap_x/" \
        -e "s/^gap_y .*/gap_y $new_gap_y/" \
        "$src" > "$dst"
}

# For the Lua-style cool_date config, scaling is different
generate_scaled_cool_date() {
    local src="$1"
    local dst="$2"

    local orig_gap_x orig_gap_y
    orig_gap_x=$(grep -oP 'gap_x\s*=\s*\K-?[0-9]+' "$src")
    orig_gap_y=$(grep -oP 'gap_y\s*=\s*\K-?[0-9]+' "$src")

    local new_gap_x new_gap_y
    new_gap_x=$(awk "BEGIN {printf \"%d\", $orig_gap_x * $SCREEN_W / $BASE_W}")
    new_gap_y=$(awk "BEGIN {printf \"%d\", $orig_gap_y * $SCREEN_H / $BASE_H}")

    sed -e "s/gap_x = $orig_gap_x/gap_x = $new_gap_x/" \
        -e "s/gap_y = $orig_gap_y/gap_y = $new_gap_y/" \
        "$src" > "$dst"
}

# Generate scaled configs in /tmp
CONKY_TMP="/tmp/conky_scaled_$$"
mkdir -p "$CONKY_TMP"

# Old-style configs (usage_and_temp, disk, mem, procs)
for widget in usage_and_temp disk mem procs; do
    generate_scaled_config "$CURRENT_DIR/$widget" "$CONKY_TMP/$widget"
done

# Lua-style config (cool_date)
generate_scaled_cool_date "$CURRENT_DIR/cool_date" "$CONKY_TMP/cool_date"

# Start all the widgets using the scaled configs
(conky -c "$CONKY_TMP/usage_and_temp" &> /dev/null &)
(conky -c "$CONKY_TMP/disk" &> /dev/null &)
(conky -c "$CONKY_TMP/mem" &> /dev/null &)
(conky -c "$CONKY_TMP/procs" &> /dev/null &)
(conky -c "$CONKY_TMP/cool_date" &> /dev/null &)
