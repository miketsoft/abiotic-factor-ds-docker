#!/bin/bash
set -e

WINEPREFIX="${WINEPREFIX:-${USER_HOME}/.wine}"
export WINEPREFIX

# Создаём Wine-префикс при первом запуске.
if [[ ! -d "${WINEPREFIX}" ]]; then
    echo "Initializing Wine prefix..."
    wineboot --init
fi

ARGS=(
    "-MaxServerPlayers=${MaxServerPlayers:-3}"
    "-PORT=7777"
    "-ServerPassword=${ServerPassword:-password}"
    "-SteamServerName=${SteamServerName:-LinuxServer}"
    "-WorldSaveName=${WorldSaveName:-Cascade}"
    "-tcp"
)
if [[ "${UsePerfThreads:-true}" != "false" ]]; then
    ARGS+=("-useperfthreads")
fi
if [[ "${NoAsyncLoadingThread:-true}" != "false" ]]; then
    ARGS+=("-NoAsyncLoadingThread")
fi
if [[ "${UseQueryPort:-true}" != "false" ]]; then
    ARGS+=("-QueryPort=27015")
fi
if [[ -n "${AdditionalArgs:-}" ]]; then
    # shellcheck disable=SC2206
    ARGS+=(${AdditionalArgs})
fi

cd "/home/steam/game/AbioticFactor/Binaries/Win64"
exec wine AbioticFactorServer-Win64-Shipping.exe "${ARGS[@]}"
