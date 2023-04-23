#!/bin/bash

source ./links.sh
source ./helper-functions.sh

echor "Phase 3"

(
   cd installation || echor "Couldn't go into installation folder, aborting."

   # Setting up arch
   echog "Setting up repositories"
   echo "Color" | sudo tee -a /etc/pacman.conf
   echo "[multilib]" | sudo tee -a /etc/pacman.conf
   echo "Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
   echog "Setting up locales"
   echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
   sudo pacman -Syu glibc lib32-glibc --noconfirm
   echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf
   echo "LC_ALL=en_US.UTF-8" | sudo tee /etc/locale.conf
   echo "export LANG=en_US.UTF-8 #alvr-distrobox" | tee -a ~/.bashrc
   echo "export LC_ALL=en_US.UTF-8 #alvr-distrobox" | tee -a ~/.bashrc
)

exit 0
