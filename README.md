## Installing ALVR and using SteamVR on Linux through Distrobox

## Disclaimer

1. This is just an attempt to make things easier for Linux users to use ALVR, SteamVR. By no means it's a comprehensive, fully featured and 100% working guide. Please open new issues and pull requests to correct this guide, scripts, etc etc.

2. This guide is not adjusted for Intel gpu owners yet. Only NVIDIA and AMDGPU.

3. Slimevr, OpenVRAS, Open Space Calibrator are all possible to launch and use on Linux, but this guide/script is not adjusted yet.

4. Currently this guide doesn't include configuration guide for ALVR itself to make it work better, so you will have to do it yourself.

5. Microphone configuration currently isn't done yet, only in the startup script and not explained.

6. Firewall configuration is skipped entirely and setup firewall configuration is broken, so it might not work in case you have strict firewall (alvr docs should have info about that).

7. Don't use SteamVR Beta (1.26+) version, it contains a lot of breaking changes that are yet to be tested to work with.

## installing alvr in distrobox

After you have installed Podman and Distrobox in your system, you can begin installing environment and ALVR with it.

Open terminal in this repository folder and do:

1. `./setup-outside-distrobox.sh`
   
    This prepares distrobox, podman if they are needed to be installed and used, as well as basic installation of packages inside distrobox. Follow steps from that script.

2. When you're done with `./setup-outside-distrobox.sh`, it will automatically enter container and you need to launch main guidance script with `./setup-inside-distrobox.sh`. From there, pay close attention to green, and especially red text and follow it.

## Additional info

Highly recommend using CoreCtrl and setting settings to VR profile for **AMD** gpus, as well as cpu to performance profile (if it's a Ryzen cpu). Without setting those gpu profiles, you **will** have serious shutters/wobbles at random point while playing ([[PERF] Subpar GPU performance due to wrong power profile mode · Issue #469 · ValveSoftware/SteamVR-for-Linux · GitHub](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/469)).
