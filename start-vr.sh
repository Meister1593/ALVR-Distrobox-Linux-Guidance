#!/bin/bash

# credits to original script go to galister#4182

source ./helper-functions.sh

# go to installation folder in case we aren't already there
cd installation || echog "Already at needed folder"

STEAMVR_PATH="$HOME/.local/share/Steam/steamapps/common/SteamVR"
LATEST_SINK_MIC_ID=-1
LATEST_SOURCE_MIC_ID=-1

# add your tools here
run_additional_stuff() {
  echog Starting additional software
  ./alvr/usr/bin/alvr_dashboard &
  # WIP:
  #./SlimeVR-amd64.appimage &
  #./arch-alvr/oscalibrator-fork/OpenVR-SpaceCalibrator/openvr-spacecalibrator &
}

run_vrstartup() {
  "$STEAMVR_PATH/bin/vrstartup.sh" >/dev/null 2>&1 &
}

function get_alvr_playback_sink_id() {
  local last_node_name=''
  local last_node_id=''
  pactl list sink-inputs | while read -r line; do
    node_id=$(echo "$line" | grep -oP 'Sink Input #\K.+' | sed -e 's/^[ \t]*//')
    node_name=$(echo "$line" | grep -oP 'node.name = "\K[^"]+' | sed -e 's/^[ \t]*//')
    if [[ "$node_id" != '' ]] && [[ "$last_node_id" != "$node_id" ]]; then
      last_node_id="$node_id"
    fi
    if [[ -n "$node_name" ]] && [[ "$last_node_name" != "$node_name" ]]; then
      last_node_name="$node_name"
      if [[ "$last_node_name" == "alsa_playback.vrserver" ]]; then
        echo "$last_node_id"
        return
      fi
    fi
  done
}

function get_alvr_sink_id() {
  pactl list short sinks | grep ALVR-MIC-Sink | cut -d$'\t' -f1
}

function setup_mic() {
  echog "Creating microphone sink & source and linking alvr playback to it"
  # This sink is required so that it persistently auto-connects to alvr playback later
  LATEST_SINK_MIC_ID=$(pactl load-module module-null-sink sink_name=ALVR-MIC-Sink media.class=Audio/Sink)
  # This source is required so that any app can use it as microphone
  LATEST_SOURCE_MIC_ID=$(pactl load-module module-null-sink sink_name=ALVR-MIC-Source media.class=Audio/Source/Virtual)
  # We link them together
  pw-link ALVR-MIC-Sink ALVR-MIC-Source
  # And we assign playback of pipewire alsa playback to created alvr sink
  pactl move-sink-input "$(get_alvr_playback_sink_id)" "$(get_alvr_sink_id)"
}

function unload_mic() {
  echog "Unloading microphone sink & source"
  pactl unload-module "$LATEST_SINK_MIC_ID"
  pactl unload-module "$LATEST_SOURCE_MIC_ID"
}

if pidof vrmonitor >/dev/null; then
  # we're started with vr already running so just start the extras
  run_additional_stuff
fi

trap 'echo SIGINT!; cleanup_alvr; unload_mic; exit 0' INT
trap 'echo SIGTERM!; cleanup_alvr; unload_mic; exit 0' TERM

while true; do

  if ! pidof vrmonitor >/dev/null; then
    cleanup_alvr
    unload_mic

    run_vrstartup
    sleep 12
    setup_mic
    run_additional_stuff
  fi

  sleep 1
done
