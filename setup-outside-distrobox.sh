#!/bin/bash

source ./helper-functions.sh

function detect_gpu() {
   local gpu
   gpu=$(lspci | grep -i vga)
   if echo "$gpu" | grep -q -i amd; then
      echo 'amd'
   elif echo "$gpu" | grep -q -i nvidia; then
      local driver_string
      local is_open
      driver_string=$(</proc/driver/nvidia/version)
      if [[ "$driver_string" == *"Open"* ]]; then
         is_open=true
      fi
      local driver_version
      if [[ "$is_open" == true ]]; then
         driver_version=$(echo "$driver_string" | head -1 | tail -2 | tr -s ' ' | cut -d' ' -f10)
      else
         driver_version=$(echo "$driver_string" | head -1 | tail -2 | tr -s ' ' | cut -d' ' -f8)
      fi
      echo "nvidia $driver_version"
   else
      echo 'intel'
   fi
}

function detect_audio() {
   if [[ -n "$(pgrep pipewire)" ]]; then
      echo 'pipewire'
   elif [[ -n "$(pgrep pulseaudio)" ]]; then
      echo 'pulse'
   else
      echo 'none'
   fi
}

function phase1_distrobox_podman_install() {
   echor "Phase 1"
   mkdir installation
   (
      cd installation || exit

      # Installing distrobox from git because script installs latest release without distrobox-assemble functionality
      mkdir distrobox
      git clone https://github.com/89luca89/distrobox.git distrobox-git
      (
         cd distrobox-git || exit
         ./install --prefix ../distrobox
      )

      rm -rf distrobox-git

      if [[ -z "$(which podman)" ]]; then
         echog "Could not find podman in system path, installing locally"
         mkdir podman
         curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/install-podman | sh -s -- --prefix "$PWD/podman"
      else
         echog "Found Podman installation on your system, not installing podman locally."
      fi
   )
}

function phase2_distrobox_cotainer_creation() {
   echor "Phase 2"
   GPU=$(detect_gpu)
   AUDIO_SYSTEM=$(detect_audio)

   source ./setup-env.sh
   if [[ "$GPU" == "amd" ]]; then
      echo "amd" | tee -a ./installation/specs.conf
      distrobox-assemble create -f ./distrobox-amd.ini
   elif [[ "$GPU" == nvidia* ]]; then
      echo "$GPU" | tee -a ./installation/specs.conf
      distrobox-assemble create -f ./distrobox-nvidia.ini
   else
      echor "Intel is not supported yet."
      exit 1
   fi
   if [[ "$AUDIO_SYSTEM" == "pipewire" ]]; then
      echo "pipewire" | tee -a ./installation/specs.conf
   elif [[ "$AUDIO_SYSTEM" == "pulse" ]]; then
      echo "pulse" | tee -a ./installation/specs.conf
   else
      echor "Unsupported audio system. Please report this issue."
      exit 1
   fi

   distrobox-enter --name arch-alvr -- bash -c './setup-inside-distrobox.sh'
}

phase1_distrobox_podman_install
phase2_distrobox_cotainer_creation
