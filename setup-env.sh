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

prefix="installation"

# If someone uses this setup env to use prefixed installation, initialise prefix var
init_prefixed_installation "$@"

CONTAINERS_CONF=$PWD/$prefix/.config/containers/containers.conf
CONTAINERS_REGISTRIES_CONF=$PWD/$prefix/.config/containers/registries.conf
CONTAINERS_STORAGE_CONF=$PWD/$prefix/.config/containers/storage.conf
PATH=$PWD/$prefix/podman/bin:$PWD/$prefix/distrobox/bin:$PATH

# what even is this podman? it doesn't inherit from environment
alias distrobox="CONTAINERS_CONF=$CONTAINERS_CONF CONTAINERS_REGISTRIES_CONF=$CONTAINERS_REGISTRIES_CONF CONTAINERS_STORAGE_CONF=$CONTAINERS_STORAGE_CONF distrobox"
alias podman="CONTAINERS_CONF=$CONTAINERS_CONF CONTAINERS_REGISTRIES_CONF=$CONTAINERS_REGISTRIES_CONF CONTAINERS_STORAGE_CONF=$CONTAINERS_STORAGE_CONF podman"
