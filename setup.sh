#!/bin/bash

source ./helper-functions.sh

prefix="installation"
container_name="arch-alvr"

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
   mkdir $prefix
   (
      cd $prefix || exit

      echog "Installing rootless podman locally"
      mkdir podman
      curl -s https://raw.githubusercontent.com/Meister1593/distrobox/test/extras/install-podman | sh -s -- --prefix "$PWD" # temporary linked to own repository until MR passes


      # Installing distrobox from git because it is much newer
      mkdir distrobox
      git clone https://github.com/89luca89/distrobox.git distrobox-git
      (
         cd distrobox-git || exit
         ./install --prefix ../distrobox
      )

      rm -rf distrobox-git
   )
}

function phase2_distrobox_container_creation() {
   echor "Phase 2"
   GPU=$(detect_gpu)
   AUDIO_SYSTEM=$(detect_audio)

   source ./setup-dev-env.sh $prefix

   if [[ "$(which podman)" != "$PWD/$prefix/podman/bin/podman" ]]; then
      echor "Failed to install podman properly"
      exit 1
   fi

   if [[ "$(which distrobox)" != "$PWD/$prefix/distrobox/bin/distrobox" ]]; then
      echor "Failed to install podman properly"
      exit 1
   fi

   echo "$GPU" | tee -a ./$prefix/specs.conf
   if [[ "$GPU" == "amd" ]]; then
      distrobox create --pull --image docker.io/library/archlinux:latest \
         --name $container_name \
         --home "$PWD/$prefix/$container_name"
      if [ $? -ne 0 ]; then
         echor "Couldn't create distrobox container, please report it to maintainer."
         exit 1
      fi
   elif [[ "$GPU" == nvidia* ]]; then
      CUDA_LIBS="$(find /usr/lib* -iname "libcuda*.so*")"
      if [[ -z $CUDA_LIBS ]]; then
         echor "Couldn't find CUDA on host, please install it as it's required for NVENC support."
         exit 1
      fi
      distrobox create --pull --image docker.io/library/archlinux:latest \
         --name $container_name \
         --nvidia \
         --home "$PWD/$prefix/$container_name"
      if [ $? -ne 0 ]; then
         echor "Couldn't create distrobox container, please report it to maintainer."
         exit 1
      fi
   else
      echor "Intel is not supported yet."
      exit 1
   fi
   if [[ "$AUDIO_SYSTEM" == "pipewire" ]]; then
      echo "pipewire" | tee -a ./$prefix/specs.conf
   elif [[ "$AUDIO_SYSTEM" == "pulse" ]]; then
      echo "pulse" | tee -a ./$prefix/specs.conf
   else
      echor "Unsupported audio system. Please report this issue."
      exit 1
   fi
   
   distrobox enter --name $container_name --additional-flags "--env prefix=$prefix --env container_name=$container_name" -- ./setup-inside-distrobox-phase-3.sh
   if [ $? -ne 0 ]; then
      echor "Couldn't install distrobox container first time, please report it to maintainer."
      exit 1
   fi
   distrobox stop --name $container_name --yes
   distrobox enter --name $container_name --additional-flags "--env prefix=$prefix --env container_name=$container_name --env LANG=en_US.UTF-8 --env LC_ALL=en_US.UTF-8" -- ./setup-inside-distrobox-phase-4.sh
   if [ $? -ne 0 ]; then
      echor "Couldn't install distrobox container first time, please report it to maintainer."
      # envs are required! otherwise first time install won't have those env vars, despite them being even in bashrc, locale conf, profiles, etc
      exit 1
   fi
}

init_prefixed_installation "$@"
phase1_distrobox_podman_install
#phase2_distrobox_container_creation
