#!/bin/bash

source ./helper-functions.sh

# Required on xorg setups
if [[ -z $WAYLAND_DISPLAY ]]; then
    xhost "+si:localuser:$USER"
    if [ $? -ne 0 ]; then
        echo "Couldn't use xhost, please install it and re-run installation"
        exit 1
    fi
fi

prefix="$1"

export CONTAINERS_CONF=$PWD/$prefix/.config/containers/containers.conf
export CONTAINERS_REGISTRIES_CONF=$PWD/$prefix/.config/containers/registries.conf
export CONTAINERS_STORAGE_CONF=$PWD/$prefix/.config/containers/storage.conf
export PATH=$PWD/$prefix/podman/bin:$PWD/$prefix/distrobox/bin:$PATH