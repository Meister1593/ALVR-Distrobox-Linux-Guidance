#!/bin/bash

if [[ -e $PWD/installation/podman ]]; then
    PATH=$PATH:$PWD/installation/podman/bin
fi

PATH=$PATH:$PWD/installation/distrobox/bin
