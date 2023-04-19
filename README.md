## Installing ALVR and using SteamVR on Linux through Distrobox

## Disclaimer

1. This is just an attempt to make things easier for Linux users to use ALVR, SteamVR. By no means it's a comprehensive, fully featured and 100% working guide. Please open new issues and pull requests to correct this guide, scripts, etc etc.

2. This guide is not adjusted for Intel gpu owners yet. Only NVIDIA and AMDGPU (Low priority TODO).

3. Slimevr, OpenVRAS, Open Space Calibrator are all possible to launch and use on Linux, but this guide/script is not adjusted yet (Medium priority TODO).

4. Currently this guide doesn't include configuration guide for ALVR itself to make it work better, so you will have to do it yourself (High priority TODO).

5. Microphone configuration currently isn't done yet, only in the startup script and not explained (High priority TODO).

6. Firewall configuration is skipped entirely and setup firewall configuration is broken, so it might not work in case you have strict firewall (alvr docs should have info about that) (Low priority TODO).

7. Don't use SteamVR Beta (1.26+) version, it contains a lot of breaking changes that are yet to be tested to work with.

8. If you're already using Distrobox, this will override your user PATH variable and use distrobox from this repository instead of your currently installed. This by itself isn't a problem for using distrobox containers. but it may be crumblesome in case you want to remove it using uninstaler, as it will also remove all previous desktop icons you have.

9. KDE Nvidia Wayland users might encounter SteamVR 307 crash, which would mean that they have to use X11 session for VR unfortunately. Installation using these scripts can be still completed, even with those errors, but vr still have to be used from X11.

## Installing alvr in distrobox

After you have installed Podman and Distrobox in your system, you can begin installing environment and ALVR with it.

Open terminal in this repository folder and do:

1. `./setup-outside-distrobox.sh`
   
    This prepares distrobox, podman if they are needed to be installed and used, as well as basic installation of packages inside distrobox. Follow steps from that script.

2. When you're done with `./setup-outside-distrobox.sh`, it will automatically enter container and you need to launch main guidance script with `./setup-inside-distrobox.sh`. From there, pay close attention to green, and especially red text and follow it.

## Updating ALVR & WlxOverlay

In case there was an update for ALVR or WlxOverlay, you can manually update links in `links.sh` file and run `./update-vr-apps.sh`. For automatic update, usually someone from maintainers have to update `links.sh` and then after pulling new version you just run `./update-vr-apps.sh`.

For the moment, this process is semi-automaitc/manual to ensure that end user won't have any possible issue with specific alvr/wlxoverlay version when the first-time installation has occurred.

## Uninstalling

To uninstall this, simply run `./uninstall-distrobox.sh` and it will automatically remove podman (if was installed locally), distrobox, and all PATH changes that were made by this script.

## Additional info

Highly recommend using CoreCtrl and setting settings to VR profile for **AMD** gpus, as well as cpu to performance profile (if it's a Ryzen cpu). Without setting those gpu profiles, you **will** have serious shutters/wobbles/possibly crashes (sway users) at random point while playing ([[PERF] Subpar GPU performance due to wrong power profile mode · Issue #469 · ValveSoftware/SteamVR-for-Linux · GitHub](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/469)).
