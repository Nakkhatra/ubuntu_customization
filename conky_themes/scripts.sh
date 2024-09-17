#!/bin/bash

# Get the directory of the current script
CURRENT_DIR="$(dirname "$(realpath "$0")")"

# This command will close all active conky
killall conky
sleep 2s

# Start all the widgets using the current directory path
(conky -c "$CURRENT_DIR/usage_and_temp" &> /dev/null &)
(conky -c "$CURRENT_DIR/disk" &> /dev/null &)
(conky -c "$CURRENT_DIR/mem" &> /dev/null &)
(conky -c "$CURRENT_DIR/procs" &> /dev/null &)
(conky -c "$CURRENT_DIR/cool_date" &> /dev/null &)


