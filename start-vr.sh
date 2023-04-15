#!/bin/bash

# credits to original script go to galister#4182

# go to installation folder in case we aren't already there
cd installation

STEAMVR_PATH="$HOME/.local/share/Steam/steamapps/common/SteamVR"
LATEST_MIC_ID=-1

# add your tools here
run_additional_stuff() {
   echo Starting additional stuff
   ./alvr/usr/bin/alvr_dashboard &
}

run_vrstartup() {
  setup_mic
  $STEAMVR_PATH/bin/vrstartup.sh > /dev/null 2>&1 &
}

cleanup() {
   unload_mic
   for vrp in vrdashboard vrcompositor vrserver vrmonitor vrwebhelper vrstartup alvr_dashboard; do
     pkill -f $vrp
   done

   sleep 3

   for vrp in vrdashboard vrcompositor vrserver vrmonitor vrwebhelper vrstartup alvr_dashboard; do
     pkill -f -9 $vrp
   done
}


function setup_mic(){
   LATEST_MIC_ID=$(pactl load-module module-null-sink sink_name=VirtMic)
}

function unload_mic(){
   pactl unload-module $LATEST_MIC_ID
}

if pidof vrmonitor >/dev/null; then
  # we're started with vr already running so just start the extras
  run_additional_stuff
fi

trap 'echo SIGINT!; cleanup; exit 0' INT
trap 'echo SIGTERM!; cleanup; exit 0' TERM

while true; do 
  
  if ! pidof vrmonitor >/dev/null; then
    cleanup

    run_vrstartup

    sleep 12
    run_additional_stuff
  fi

  sleep 1
done
