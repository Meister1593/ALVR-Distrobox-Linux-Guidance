#!/bin/bash

source ./setup-env.sh

# Required on xorg setups 
if [[ -z $WAYLAND_DISPLAY ]]; then
    xhost "+si:localuser:$USER"
fi

distrobox-enter --name arch-alvr -- bash -c './start-vr.sh'
