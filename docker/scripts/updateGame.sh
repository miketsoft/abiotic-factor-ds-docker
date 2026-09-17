#!/bin/bash
set -euo pipefail

exec "${USER_HOME}/steamcmd/steamcmd.sh" \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir "${USER_HOME}/game" \
    +login anonymous \
    +app_update 2857200 \
    +quit
