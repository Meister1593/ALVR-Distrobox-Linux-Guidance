#!/bin/bash

GPU=$(lspci | grep -i vga)

if [[ -n "$(echo $GPU | grep -i amd)" ]]; then
   GPU='amd'
   distrobox-assemble create -f distrobox-amd.ini
elif [[ -n "$(echo $GPU | grep -i nvidia)" ]]; then
   GPU='nvidia'
   distrobox-assemble create -f distrobox-nvidia.ini
else
   echo "Intel is not supported yet."
   exit 0
fi

if [[ -e "installation" ]]; then
   cd installation
   if [[ "$GPU" == "amd" ]]; then
      echo "amd" | tee -a specs.conf
      distrobox-assemble create -f ../distrobox-amd.ini
   elif [[ "$GPU" == "nvidia" ]]; then
      echo "nvidia" | tee -a specs.conf
      distrobox-assemble create -f ../distrobox-nvidia.ini
   else
      echo "Intel is not supported yet."
      exit 0
   fi
   if [[ -n "$(pgrep pipewire)" ]]; then
      echo "pipewire" | tee -a specs.conf
   else [[ -n "$(pgrep pulseaudio)" ]]; then
      echo "pulse" | tee -a specs.conf
   else
      echo "Unsupported audio system"
      exit 0
   fi
   
   distrobox-enter arch-alvr
else
   mkdir installation
   cd installation
   
   # Installing distrobox and podman
   # installing distrobox from git because script installs latest release (not what we want)
   git clone https://github.com/89luca89/distrobox.git distrobox-git
   mkdir distrobox
   ./distrobox-git/install --prefix $PWD/distrobox
   
   if [[ -z "$(which podman)" ]]; then
      echo "Could not find podman in system path, installing locally"
      mkdir podman
      curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/install-podman | sh -s -- --prefix $PWD/podman
   else
     echo "Found Podman installation on your system, using that"
   fi
   
   # Appending paths for distrobox and podman to bashrc
   echo 'export PATH=$HOME/.local/bin:$PATH #alvr-distrobox' | tee -a ~/.bashrc
   echo 'export PATH=$HOME/.local/podman/bin:$PATH #alvr-distrobox' | tee -a ~/.bashrc
   
   echo "Please re-enter your terminal application and re-run this script to continue in next step."
fi
