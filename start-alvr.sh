#!/bin/bash

source ./setup-env.sh
source ./helper-functions.sh

# Required on xorg setups
if [[ -z $WAYLAND_DISPLAY ]]; then
    xhost "+si:localuser:$USER" || (echor "Couldn't use xhost, please install it" && exit 1)
fi

echog "Starting up Steam"
distrobox-enter --name arch-alvr --additional-flags "--env LANG=en_US.UTF-8 --env LC_ALL=en_US.UTF-8" -- steam &>/dev/null &
echog "Starting up ALVR"
distrobox-enter --name arch-alvr --additional-flags "--env LANG=en_US.UTF-8 --env LC_ALL=en_US.UTF-8" -- ./start-vr.sh
