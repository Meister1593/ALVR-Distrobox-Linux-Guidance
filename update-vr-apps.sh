#!/bin/bash

prefix="installation"

source ./links.sh
source ./helper-functions.sh

init_prefixed_installation "$@"
source ./setup-dev-env.sh "$prefix"

echog "Deleting existing alvr"
rm -r $prefix/alvr installation/ALVR-x86_64.AppImage
wget -q --show-progress -P $prefix/ "$ALVR_LINK"
chmod +x "$prefix/$ALVR_FILENAME"
"$prefix"/./"$ALVR_FILENAME" --appimage-extract
mv squashfs-root $prefix/alvr

echog "Deleting existing wlxoverlay"
rm "$prefix/WlxOverlay-v*-x86_64.AppImage*"
wget -q --show-progress -P "$prefix/" "$WLXOVERLAY_LINK"
chmod +x "$prefix/$WLXOVERLAY_FILENAME"

echog "Installation finished. Run ALVR as usual and make sure to open WlxOverlay from inside container once to make it auto-start from steamvr."
