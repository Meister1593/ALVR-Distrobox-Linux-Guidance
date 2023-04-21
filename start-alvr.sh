#!/bin/bash

source ./setup-env.sh
source ./helper-functions.sh

# Required on xorg setups 
if [[ -z $WAYLAND_DISPLAY ]]; then
    xhost "+si:localuser:$USER" || (echor "Couldn't use xhost, please install it" && exit 1)
fi

distrobox-enter --name arch-alvr -- bash -c './start-vr.sh'
