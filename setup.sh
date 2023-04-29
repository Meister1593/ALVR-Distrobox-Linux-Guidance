#!/bin/bash

source ./helper-functions.sh

prefix="installation"
container_name="arch-alvr"

function detect_gpu() {
   local gpu
   gpu=$(lspci | grep -i vga | tr '[:upper:]' '[:lower:]')
   if [[ $gpu == *"amd"* ]]; then
      echo 'amd'
      return
   elif [[ $gpu == *"nvidia"* ]]; then
      echo 'nvidia'
      return
   else
      echo 'intel'
      return
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
      curl -s https://raw.githubusercontent.com/Meister1593/distrobox/test/extras/install-podman | sh -s -- --verbose --prefix "$PWD" --prefix-name "$container_name" # temporary linked to own repository until MR passes


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

   echo $prefix

   if [[ "$(which podman)" != "$prefix/podman/bin/podman" ]]; then
      echor "Failed to install podman properly"
      exit 1
   fi

   if [[ "$(which distrobox)" != "$prefix/distrobox/bin/distrobox" ]]; then
      echor "Failed to install distrobox properly"
      exit 1
   fi

   echo "$GPU" | tee -a $prefix/specs.conf
   if [[ "$GPU" == "amd" ]]; then
      distrobox create --pull --image docker.io/library/archlinux:latest \
         --name $container_name \
         --home "$prefix/$container_name"
      if [ $? -ne 0 ]; then
         echor "Couldn't create distrobox container, please report it to maintainer."
         echor "GPU: $GPU; AUDIO SYSTEM: $AUDIO_SYSTEM"
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
         --home "$prefix/$container_name"
      if [ $? -ne 0 ]; then
         echor "Couldn't create distrobox container, please report it to maintainer."
         echor "GPU: $GPU; AUDIO SYSTEM: $AUDIO_SYSTEM"
         exit 1
      fi
   else
      echor "Intel is not supported yet."
      exit 1
   fi

   if [[ "$AUDIO_SYSTEM" == "pipewire" ]] || [[ "$AUDIO_SYSTEM" == "pulse" ]]; then
      echo "$AUDIO_SYSTEM" | tee -a $prefix/specs.conf
   else
      echor "Unsupported audio system ($AUDIO_SYSTEM). Please report this issue."
      exit 1
   fi
   
   distrobox enter --name $container_name --additional-flags "--env prefix=$prefix --env container_name=$container_name" -- ./setup-phase-3.sh
   if [ $? -ne 0 ]; then
      echor "Couldn't install distrobox container first time at phase 3, please report it to maintainer."
      exit 1
   fi
   distrobox stop --name $container_name --yes
   distrobox enter --name $container_name --additional-flags "--env prefix=$prefix --env container_name=$container_name --env LANG=en_US.UTF-8 --env LC_ALL=en_US.UTF-8" -- ./setup-phase-4.sh
   if [ $? -ne 0 ]; then
      echor "Couldn't install distrobox container first time at phase 4, please report it to maintainer."
      # envs are required! otherwise first time install won't have those env vars, despite them being even in bashrc, locale conf, profiles, etc
      exit 1
   fi
}

init_prefixed_installation "$@"
phase1_distrobox_podman_install
phase2_distrobox_container_creation
