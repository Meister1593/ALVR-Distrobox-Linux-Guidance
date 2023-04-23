#!/bin/bash

source ./setup-env.sh
source ./helper-functions.sh

echog "Say y to every answer from this script to complete uninstallation"

podman stop arch-alvr

distrobox-rm arch-alvr

(
cd installation || exit
if [[ -e $PWD/podman ]]; then
   curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/install-podman | sh -s -- --prefix "$PWD/podman" --remove
fi

if [[ -e $PWD/distrobox ]]; then
   curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/uninstall | sh -s -- --prefix "$PWD/distrobox"
fi
)

rm -rf installation
