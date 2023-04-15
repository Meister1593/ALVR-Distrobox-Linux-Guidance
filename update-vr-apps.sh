#!/bin/bash
source links.sh

echo "Deleting existing alvr"
rm -r installation/alvr installation/ALVR-x86_64.AppImage
wget -q --show-progress -P installation/ "$ALVR_LINK"
chmod +x "installation/$ALVR_FILENAME"
installation/./$ALVR_FILENAME --appimage-extract
mv squashfs-root installation/alvr

echo "Deleting existing wlxoverlay"
rm installation/WlxOverlay-v*-x86_64.AppImage
wget -q --show-progress -P installation/ "$WLXOVERLAY_LINK"
chmod +x "installation/$WLXOVERLAY_FILENAME"

echo "Installation finished. Run ALVR as usual and make sure to open WlxOverlay from inside container once to make it auto-start from steam."
