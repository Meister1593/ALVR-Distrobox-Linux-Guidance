#!/bin/bash

source ./links.sh
source ./helper-functions.sh

echor "Phase 3"

STEP_INDEX=1

cd installation || echog "Already in installation folder"

# Get current gpu and version in case if it's nvidia from configuration
GPU="$(head <specs.conf -1 | tail -2)"
GPU_VERSION=''
if [[ "$GPU" == nvidia* ]]; then
   GPU_VERSION=$(echo "$GPU" | cut -d' ' -f2)
   GPU=$(echo "$GPU" | cut -d' ' -f1)
fi

AUDIO_SYSTEM="$(head <specs.conf -2 | tail -1)"

echog "Found $GPU gpu and $AUDIO_SYSTEM"

# Setting up arch
echog "Setting up repositories"
echo "Color" | sudo tee -a /etc/pacman.conf
echo "[multilib]" | sudo tee -a /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
echog "Setting up locales"
echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf
echo "LC_ALL=en_US.UTF-8" | sudo tee /etc/locale.conf
echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
echo "export LANG=en_US.UTF-8 #alvr-distrobox" | tee -a ~/.bashrc
echo "export LC_ALL=en_US.UTF-8 #alvr-distrobox" | tee -a ~/.bashrc
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen

echog "Installing packages for base functionality."
sudo pacman -Syu git vim base-devel noto-fonts xdg-user-dirs fuse libx264 sdl2 libva-utils --noconfirm || exit 1
echog "Installing steam, audio and driver packages."
if [[ "$GPU" == "amd" ]]; then
   sudo pacman -Syu libva-mesa-driver vulkan-radeon lib32-vulkan-radeon lib32-libva-mesa-driver --noconfirm || exit 1
elif [[ "$GPU" == "nvidia" ]]; then
   sudo pacman -Syu nvidia-utils lib32-nvidia-utils cuda --noconfirm || exit 1

   # Installing downgrade in case needed for nvidia users
   git clone https://aur.archlinux.org/downgrade.git
   (
      cd downgrade || exit
      makepkg -si
   )

   NVIDIA_UTILS_VERSION=$(pacman -Q "nvidia-utils" | cut -d' ' -f2)
   NVIDIA_UTILS_VERSION=${NVIDIA_UTILS_VERSION%-*}
   echog "Host drivers version: $GPU_VERSION"
   echog "Distrobox drivers version: $NVIDIA_UTILS_VERSION"
   if [[ "$GPU_VERSION" != "$NVIDIA_UTILS_VERSION" ]]; then
      echor "Your host drivers are not the same as in distrobox, meaning that you probably need to downgrade them inside distrobox. Please both packages with same version as on host."
      echor "If this is a mistake, you can just choose the same versions and report this as a bug (in parsing nvidia version))"
      sudo downgrade lib32-nvidia-utils nvidia-utils
      echor "Make sure that driver versions are the same at all times, so when you update host drivers, make sure to update drivers (sudo pacman -Syu) in distrobox too."
   else
      echor "Your driver versions match from host and distrobox! Installation continues."
   fi
else
   echor "Couldn't determine gpu with name: $GPU ($GPU_VERSION), exiting!"
   exit 1
fi
if [[ "$AUDIO_SYSTEM" == "pipewire" ]]; then
   sudo pacman -Syu lib32-pipewire pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber --noconfirm || exit 1
elif [[ "$AUDIO_SYSTEM" == "pulseaudio" ]]; then
   sudo pacman -Syu pulseaudio pusleaudio-alsa --noconfirm || exit 1
else
   echor "Couldn't determine audio system: $AUDIO_SYSTEM, you may have issues with audio!"
fi

sudo pacman -Syu steam --noconfirm
# echog "Exporting steam to host as an application. It will show up as Steam (Runtime) (on arch-alvr). "
# distrobox-export --app steam

STEP_INDEX=2
sleep 2

# Ask user for installing steamvr
echog "Installed base packages and Steam. Opening steam. Please install SteamVR from it."
steam &>/dev/null &
echog "After installing SteamVR, copy (ctrl + shift + c from terminal) and launch command bellow from your host terminal shell (outside this container) and press enter to continue there. This prevents annoying popup (yes/no with asking for superuser) that prevents steamvr from launching automatically."
echog "sudo setcap CAP_SYS_NICE+ep $HOME/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher"
read
echog "Now launch SteamVR once, close it and press enter here to continue again."
read

STEP_INDEX=3
sleep 2

# installing alvr
echog "Installing alvr"
echog "This installation script assumes that you will register alvr as a driver further, so it needs to extract appimage."
wget -q --show-progress "$ALVR_LINK"
chmod +x "$ALVR_FILENAME"
./"$ALVR_FILENAME" --appimage-extract &>/dev/null
mv squashfs-root alvr
./alvr/usr/bin/alvr_dashboard &>/dev/null &
echog "ALVR and dashboard now launch and when it does that, skip setup (X button on right up corner)."
echog "After that, launch SteamVR using button on left lower corner and after starting steamvr, you should see one headset showing up in steamvr menu and 'Streamer: Connected in ALVR dashboard'."
echog "In ALVR Dashboard settings at left side, scroll all the way down and find 'Driver launch action', set it to 'No action' to prevent alvr from unregistering itself after startup."
echog "You can also untick 'Open setup wizard' too."
echog "After you have done with this, press enter here."
read
cleanup_alvr
./alvr/usr/bin/alvr_dashboard &>/dev/null &
echor "Go to 'Installation' tab at left and press 'Register ALVR driver'"
echog "After that, press press 'Launch SteamVR' at left corner and hit enter here to continue."
read
echog "Downloading ALVR apk, you can install it now from the installation folder into your headset using either ADB or Sidequest on host."
wget -q --show-progress "$ALVR_APK_LINK"
echog "From this point on, alvr will automatically start with SteamVR. But it's still quite broken mechanism so we need to use additional script for auto-restart to work."
echog "Don't close ALVR yet."

STEP_INDEX=4
sleep 2

# installing wlxoverlay
echog "Since SteamVR overlay is sort-of broken (and not that useful anyway) on Linux, we will use WlxOverlay, which works with both X11 and Wayland."
wget -q --show-progress "$WLXOVERLAY_LINK"
chmod +x "$WLXOVERLAY_FILENAME"
if [[ "$WAYLAND_DISPLAY" != "" ]]; then
   echog "If you're on wayland (and not on wlroots-based compositor), it will ask for display to choose. Choose each displays sequentially if you have more than 1."
else
   echog "If you're using Xorg, you don't need to do anything'"
fi
./"$WLXOVERLAY_FILENAME" &
if [[ "$WAYLAND_DISPLAY" != "" ]]; then
   echog "If everything went well, you might see little icon on your desktop that indicates that screenshare is happening (by WlxOverlay)"
fi
echog "WlxOverlay adds itself to auto-startup so you don't need to do anything with it to make it autostart. Press enter to continue."
read

STEP_INDEX=5
sleep 2

# patching steamvr
echog "To prevent issues with SteamVR spamming with messages into it's own web interface, i created patcher that can prevent this spam. Without this, you will have issues with opening Video Setttings per app, bindings, etc."
echog "If you're okay with patching (or have compatible SteamVR version), you can type y and press enter to patch SteamVR. Otherwise just press enter to skip"
read -r DO_PATCH
if [[ "$DO_PATCH" == "y" ]]; then
   ../patch_bindings_spam.sh "$HOME/.steam/steam/steamapps/common/SteamVR"
fi

cleanup_alvr

STEP_INDEX=6
sleep 2

# post messages
echog "From that point on, ALVR should be installed and WlxOverlay should be working. Please refer to https://github.com/galister/WlxOverlay/wiki/Getting-Started to familiarise with controls."
echor "To start alvr now you need to use start-alvr.sh script from this repository. It will also open Steam for you."
echog "In case you want to enter into container, do 'source setup-env.sh && distrobox-enter arch-alvr'"
# echor "Before launching start-alvr.sh script, please open steam (!steam from distrobox, not your main host steam!) first." # - uses system podman, script starts up steam automatically as workaround, issue: https://github.com/89luca89/distrobox/issues/716
echog "To close vr, press ctrl+c in terminal where start-alvr.sh script is running. It will automatically close alvr and steamvr."
echor "Very important: to prevent game from looking like it's severily lagging, please turn on legacy reprojection in per-app video settings in steamvr. This improves experience drastically."
echog "Tip: to prevent double-restart due to how client resets it's settings, you can change settings and then put headset to sleep, and power back. This restarts client and server, and prevents double restart."
