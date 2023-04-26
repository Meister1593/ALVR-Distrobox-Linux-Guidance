#!/bin/bash

source ./setup-env.sh

echog "Starting up Steam"
#distrobox-enter --name arch-alvr --additional-flags "--env LANG=en_US.UTF-8 --env LC_ALL=en_US.UTF-8" -- steam &>/dev/null &
echog "Starting up ALVR"
#distrobox-enter --name arch-alvr --additional-flags "--env LANG=en_US.UTF-8 --env LC_ALL=en_US.UTF-8" -- ./start-vr.sh
