#!/bin/bash

function detect_gpu() {
   local gpu=$(lspci | grep -i vga)
   if [[ -n "$(echo $gpu | grep -i amd)" ]]; then
      echo 'amd'
   elif [[ -n "$(echo $gpu | grep -i nvidia)" ]]; then
      local driver_version=$(cat /proc/driver/nvidia/version | head -1 | tail -2 | tr -s ' ' | cut -d' ' -f8)
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
GPU=$(detect_gpu)
AUDIO_SYSTEM=$(detect_audio)

function phase1_distrobox_podman_install() {
   mkdir installation
   cd installation
   
   # Installing distrobox and podman
   # installing distrobox from git because script installs latest release (not what we want)
   git clone https://github.com/89luca89/distrobox.git distrobox-git
   mkdir distrobox
   cd distrobox-git
   ./install --prefix ../distrobox
   cd ..
   
   if [[ -z "$(which podman)" ]]; then
      echo "Could not find podman in system path, installing locally"
      mkdir podman
      curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/install-podman | sh -s -- --prefix $PWD/podman
   else
     echo "Found Podman installation on your system, using that"
   fi
   
   # Appending paths for distrobox and podman to bashrc
   echo "export PATH=$PWD/distrobox/bin:\$PATH #alvr-distrobox" | tee -a ~/.bashrc
   if [[ -z "$(which podman)" ]]; then
      echo "export PATH=$PWD/podman/bin:\$PATH #alvr-distrobox" | tee -a ~/.bashrc
   fi
   echo "xhost +si:localuser:\$USER #alvr-distrobox" | tee -a ~/.bashrc # for xorg setups, doesn't work in xinitrc, need to find better place
   
   echo "Please relog from your system and re-run this script in new terminal window to continue in next step. This ensures that distrobox can be used from both new terminals and from your desktop."
}

function phase2_distrobox_cotainer_creation() {
   cd installation
   if [[ "$GPU" == "amd" ]]; then
      echo "amd" | tee -a specs.conf
      distrobox-assemble create -f ../distrobox-amd.ini
   elif [[ "$GPU" == nvidia* ]]; then
      echo "$GPU" | tee -a specs.conf
      distrobox-assemble create -f ../distrobox-nvidia.ini
   else
      echo "Intel is not supported yet."
      exit 0
   fi
   if [[ "$AUDIO_SYSTEM" == "pipewire" ]]; then
      echo "pipewire" | tee -a specs.conf
   elif [[ "$AUDIO_SYSTEM" == "pulse" ]]; then
      echo "pulse" | tee -a specs.conf
   else
      echo "Unsupported audio system"
      exit 0
   fi
   
   distrobox-enter arch-alvr
}

if [[ -e "installation" ]]; then
   phase2_distrobox_cotainer_creation
else
   phase1_distrobox_podman_install
fi
