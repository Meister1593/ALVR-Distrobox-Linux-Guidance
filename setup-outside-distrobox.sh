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

      # Installing distrobox from git because it is much newer
      mkdir distrobox
      git clone https://github.com/89luca89/distrobox.git distrobox-git
      (
         cd distrobox-git || exit
         ./install --prefix ../distrobox
      )

      rm -rf distrobox-git

      echog "Installing rootless podman locally"
      mkdir podman
      curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/install-podman | sh -s -- --prefix "$PWD/podman"
   )
}

function phase2_distrobox_cotainer_creation() {
   echor "Phase 2"
   GPU=$(detect_gpu)
   AUDIO_SYSTEM=$(detect_audio)

   source ./setup-env.sh
   if [[ "$GPU" == "amd" ]] || [[ "$GPU" == nvidia* ]]; then
      echo "$GPU" | tee -a ./installation/specs.conf
      distrobox-create --image docker.io/library/archlinux:latest \
      --name arch-alvr \
      --home "$PWD/installation/arch-alvr" || (echor "Couldn't create distrobox container, please report it to maintainer." && exit 1)
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

   distrobox-enter --name arch-alvr -- bash -c './setup-inside-distrobox.sh' \
   || (echor "Couldn't enter distrobox container first time, please report it to maintainer." && exit 1)
}

phase1_distrobox_podman_install
phase2_distrobox_cotainer_creation
