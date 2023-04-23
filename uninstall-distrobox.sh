#!/bin/bash

source ./setup-env.sh
source ./helper-functions.sh

echog "If you're using something else than 'sudo', please write it as-is now, otherwise just press enter. This is needed as podman creates container files that needs permissions to be deleted afterwards."
read -r ROOT_PERMS_COMMAND
if [[ -z $ROOT_PERMS_COMMAND ]]; then
ROOT_PERMS_COMMAND="sudo"
fi
echog "Say y to every answer from this script to complete uninstallation"

podman stop arch-alvr

distrobox-rm arch-alvr

(
cd installation || exit
if [[ -e $PWD/podman ]]; then
   curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/install-podman | sh -s -- --prefix "$PWD" --remove
fi

if [[ -e $PWD/distrobox ]]; then
   curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/uninstall | sh -s -- --prefix "$PWD/distrobox"
fi
)

$ROOT_PERMS_COMMAND rm -rf installation
