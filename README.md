## Installing ALVR and using SteamVR on Linux through Distrobox

## Disclaimer

1. This is just an attempt to make things easier for Linux users to use ALVR, SteamVR. By no means it's a comprehensive, fully featured and 100% working guide. Please open new issues and pull requests to correct this guide, scripts, etc etc.

2. This guide is not adjusted for Intel gpu owners yet. Only NVIDIA and AMDGPU (Low priority TODO).

3. Slimevr, OpenVRAS, Open Space Calibrator are all possible to launch and use on Linux, but this guide/script is not adjusted yet (Medium priority TODO).

4. Currently this guide doesn't include configuration guide for ALVR itself to make it work better, so you will have to do it yourself (High priority TODO).

5. Microphone configuration currently isn't done yet, vr startup script creates sink to be used for vr, but it's not explained (High priority TODO).

6. Firewall configuration is skipped entirely and setup firewall configuration is broken, so it might not work in case you have strict firewall (alvr docs should have info about that) (Low priority TODO).

7. Don't use SteamVR Beta (1.26+) version, it contains a lot of breaking changes that are yet to be tested to work with.

8. Some nvidia users might experience 307 steamvr crash, which is found at least with one user, and solution isn't found yet, but currently actively looking for the cause. **Possible cause - latest 530 drivers, so if you happen to have this issue - please try downgrading them to 525 on the host and re-running script. It seems like they has issues with running any container graphics software, including podman/distrobox and flatpak**

## Installing alvr in distrobox

Open terminal in this repository folder and do:

1. `./setup-outside-distrobox.sh`
   
   That's it. **Follow all green and especially red text carefully from the scripts.**
   
   After full installation, you can use `./start-alvr.sh` to launch alvr automatically.
   
   Script also downloads related apk file to install to headset into `installation` folder for you. Use Sidequest or ADB to install it.

## Updating ALVR & WlxOverlay

In case there was an update for ALVR or WlxOverlay in the repository, you can run `./update-vr-apps.sh`. In case you want to manually update ALVR or WlxOverlay versions, you can change `links.sh` file accordingly and run the same script.

## Uninstalling

To uninstall this, simply run `./uninstall-distrobox.sh` and it will automatically remove everything related to locally installed distrobox, it's containers, podman and everything inside in `installation` folder.

## Additional info

Highly recommend using CoreCtrl (install it using your distribution package management) and setting settings to VR profile for **AMD** gpus, as well as cpu to performance profile (if it's a Ryzen cpu). Without setting those gpu profiles, you **will** have serious shutters/wobbles/possibly crashes (sway users) at random point while playing ([[PERF] Subpar GPU performance due to wrong power profile mode · Issue #469 · ValveSoftware/SteamVR-for-Linux · GitHub](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/469)).
