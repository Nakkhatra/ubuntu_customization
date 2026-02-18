#!/bin/bash

# v2.0 Closebox73
# This script is to get weather data from openweathermap.com in the form of a json file
# so that conky will still display the weather when offline even though it doesn't up to date

# Variables — loaded from weather.conf (copy weather.conf.example to weather.conf and fill in your values)
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CONFIG_FILE="$SCRIPT_DIR/weather.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found. Copy weather.conf.example to weather.conf and fill in your API key." >&2
    exit 1
fi

# shellcheck source=weather.conf
source "$CONFIG_FILE"

# Main command
url="api.openweathermap.org/data/2.5/weather?id=${city_id}&appid=${api_key}&cnt=5&units=${unit}&lang=${lang}"
curl ${url} -s -o ~/.cache/weather.json

exit
