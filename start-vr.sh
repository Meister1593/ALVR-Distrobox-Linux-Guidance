#!/bin/bash

# credits to original script go to galister#4182

source ./helper_functions.sh

# go to installation folder in case we aren't already there
cd installation || echog "Already at needed folder"

STEAMVR_PATH="$HOME/.local/share/Steam/steamapps/common/SteamVR"
LATEST_MIC_ID=-1

# add your tools here
run_additional_stuff() {
   echog Starting additional stuff
   ./alvr/usr/bin/alvr_dashboard &
}

run_vrstartup() {
  setup_mic
  "$STEAMVR_PATH/bin/vrstartup.sh" > /dev/null 2>&1 &
}

function setup_mic(){
   LATEST_MIC_ID=$(pactl load-module module-null-sink sink_name=VirtMic)
}

function unload_mic(){
   pactl unload-module "$LATEST_MIC_ID"
}

if pidof vrmonitor >/dev/null; then
  # we're started with vr already running so just start the extras
  run_additional_stuff
fi

trap 'echo SIGINT!; cleanup_alvr; exit 0' INT
trap 'echo SIGTERM!; cleanup_alvr; exit 0' TERM

while true; do 
  
  if ! pidof vrmonitor >/dev/null; then
    cleanup_alvr

    run_vrstartup

    sleep 12
    run_additional_stuff
  fi

  sleep 1
done
