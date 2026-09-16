#!/bin/bash
set -e

exec /home/steam/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir /home/steam/game \
    +login anonymous \
    +app_update 2857200 \
    +quit
