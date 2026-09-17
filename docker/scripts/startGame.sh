#!/bin/bash
set -euo pipefail

validateBool() {
    case "$1" in
        true|false)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

if [[ -z "${ServerPassword:-}" ]]; then
    echo "Server password must be set" >&2
    exit 1
fi

if [[ -z "${SteamServerName:-}" ]]; then
    echo "Steam server's name must be set" >&2
    exit 1
fi

USE_PERF_THREADS="${UsePerfThreads:-true}"
NO_ASYNC_LOADING_THREAD="${NoAsyncLoadingThread:-true}"
USE_QUERY_PORT="${UseQueryPort:-true}"

if ! validateBool "$USE_PERF_THREADS"; then
    echo "UsePerfThreads must be 'true' or 'false'" >&2
    exit 1
fi
if ! validateBool "$NO_ASYNC_LOADING_THREAD"; then
    echo "NoAsyncLoadingThread must be 'true' or 'false'" >&2
    exit 1
fi
if ! validateBool "$USE_QUERY_PORT"; then
    echo "UseQueryPort must be 'true' or 'false'" >&2
    exit 1
fi

QUERY_PORT="${QueryPort:-27015}"
if ! [[ "$QUERY_PORT" =~ ^[1-9][0-9]*$ ]] || (( QUERY_PORT < 1 || QUERY_PORT > 65534 )); then
    echo "QueryPort must be a number in range 1-65534" >&2
    exit 1
fi

if [[ "$USE_QUERY_PORT" == "true" ]]; then
    APP_QUERY_PORT="$QUERY_PORT"
else
    APP_QUERY_PORT=$((QUERY_PORT + 1))
fi

if (( APP_QUERY_PORT == 7777 )); then
    echo "Query port conflicts with the game port (7777)" >&2
    exit 1
fi

WINEPREFIX="${WINEPREFIX:-${USER_HOME}/.wine}"
export WINEPREFIX

# Create the Wine prefix on the first run.
if [[ ! -d "${WINEPREFIX}" ]]; then
    echo "Initializing Wine prefix..."
    wineboot --init
fi

/usr/local/bin/updateGame.sh

ARGS=(
    "-MaxServerPlayers=${MaxServerPlayers:-3}"
    "-PORT=7777"
    "-QueryPort=${APP_QUERY_PORT}"
    "-ServerPassword=${ServerPassword}"
    "-SteamServerName=${SteamServerName}"
    "-WorldSaveName=${WorldSaveName:-Cascade}"
    "-tcp"
)
if [[ "$USE_PERF_THREADS" == "true" ]]; then
    ARGS+=("-useperfthreads")
fi
if [[ "$NO_ASYNC_LOADING_THREAD" == "true" ]]; then
    ARGS+=("-NoAsyncLoadingThread")
fi
if [[ -n "${AdditionalArgs:-}" ]]; then
    # shellcheck disable=SC2206
    ARGS+=(${AdditionalArgs})
fi

cd "/home/steam/game/AbioticFactor/Binaries/Win64"
exec wine AbioticFactorServer-Win64-Shipping.exe "${ARGS[@]}"
