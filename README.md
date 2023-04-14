## Installing ALVR and using SteamVR on Linux through Distrobox

## Disclaimer

1. This is just an attempt to make things easier for Linux users to use ALVR, SteamVR. By no means it's a comprehensive, fully featured and 100% working guide. Please open new issues and pull requests to correct this guide, scripts, etc etc.

2. This guide is not adjusted for Nvidia nor Intel gpu owners yet. Only AMDGPU.

3. Slimevr, OpenVRAS, Open Space Calibrator are all possible to launch and use on Linux, but this guide/script is not adjusted yet.

4. Currently this guide doesn't include configuration guide for ALVR itself to make it work better, so you will have to do it yourself.

5. Microphone configuration currently isn't done yet, only in the startup script and not explained.

6. Firewall configuration is skipped entirely and setup firewall configuration is broken, so it might not work in case you have strict firewall (alvr docs should have info about that).

7. Don't use SteamVR Beta (1.26+) version, it contains a lot of breaking changes that are yet to be tested to work with.

## Installing distrobox on host (git, distrobox-assemble is not out yet)

To start with this guide, you need to install distrobox on your host. 

At the moment, distrobox did not yet create a release with needed functionality, but it is available in master. So for installing distrobox, you would need to:

1. Install Podman (or Docker, but that's untested and requires to be a rootless setup)

2. Install Distrobox from their git repository.

## installing alvr in distrobox

After you have installed Podman and Distrobox in your system, you can begin installing environment and ALVR with it.

Open terminal in this repository folder and do:

1. `distrobox-assemble create`

        This prepares container to be used

1. `distrobox enter arch-alvr`
   
   This starts and opens up container, which also triggers first time installation with all needed dependencies for alvr to work. This might take a while, depending on your connection, so please be patient. In case you want to see a progress, you can use `podman logs arch-alvr` command outside to watch.

2. After entering container, you launch main guidance script with `./setup-distrobox.sh`. From there, pay close attention to green text and follow it.

## Additional info

Highly recommend using CoreCtrl and setting settings to VR profile, as well as cpu to performance profile (if it's a Ryzen cpu). Without it, you might have serious shutters/wobbles at random point while playing.
