#!/bin/bash

sed -i '/#alvr-distrobox/d' ~/.bashrc

echo "Removed PATH appends in ~/.bashrc"

if [[ -e $PWD/podman ]]; then
   curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/install-podman | sh -s -- --prefix $PWD/podman --remove
   echo "Uninstalled podman from local filesystem"
fi

if [[ -e $PWD/distrobox ]]; then
   curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/uninstall | sh -s -- --prefix $PWD/distrobox
   echo "Uninstalled distrobox from local filesystem"
fi

rm -rf installation