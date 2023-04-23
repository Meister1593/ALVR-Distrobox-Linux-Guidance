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

$ROOT_PERMS_COMMAND rm -rf installation
