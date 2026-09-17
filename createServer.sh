#!/bin/bash
set -euo pipefail

GAME_PATH="./game"
SAVES_PATH="./gameSaves"
WINE_PATH="./wine"
ENV_FILEPATH="./.env"
CONTAINER_NAME=""

showUsage() {
    echo -e "Usage: $1 [OPTIONS] containerName\n"
    echo "Options:"
    echo "  -gPath=PATH, --gamePath=PATH      Path for dedicated server files"
    echo "  -sPath=PATH, --savesPath=PATH     Path for server save data"
    echo "  -wPath=PATH, --winePath=PATH      Path for Wine files"
    echo "  -ePath=PATH, --envFilepath=PATH   Path to the .env file with container configuration variables"
}

for arg in "$@"; do
    case "$arg" in
        -h|--help)
            showUsage "$0"
            exit 0
            ;;
        -gPath=*|--gamePath=*)
            GAME_PATH="${arg#*=}"
            ;;
        -sPath=*|--savesPath=*)
            SAVES_PATH="${arg#*=}"
            ;;
        -wPath=*|--winePath=*)
            WINE_PATH="${arg#*=}"
            ;;
        -ePath=*|--envFilepath=*)
            ENV_FILEPATH="${arg#*=}"
            ;;
        -*)
            echo "Unknown argument: $arg"
            showUsage "$0"
            exit 1
            ;;
        *)
            if [[ -n "$CONTAINER_NAME" ]]; then
                echo "Unexpected argument: $arg"
                showUsage "$0"
                exit 1
            fi
            CONTAINER_NAME="$arg"
            ;;
    esac
done

if [[ -z "$CONTAINER_NAME" ]]; then
    echo "Error: name for Docker container must be set!"
    showUsage "$0"
    exit 1
fi

if [[ ! "$CONTAINER_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]+$ ]]; then
    echo "Error: invalid container name '$CONTAINER_NAME'" >&2
    exit 1
fi

if [[ ! -f "$ENV_FILEPATH" ]]; then
    echo "Error: .env not found"
    exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILEPATH"

if [[ -z "${SERVER_PASSWORD:-}" ]]; then
    echo "Error: SERVER_PASSWORD must be set!" >&2
    exit 1
fi
if [[ -z "${STEAM_SERVER_NAME:-}" ]]; then
    echo "Error: STEAM_SERVER_NAME must be set!" >&2
    exit 1
fi

QUERY_PORT="${QUERY_PORT:-27015}"

for path in "$GAME_PATH" "$SAVES_PATH" "$WINE_PATH"; do
    if [[ ! -d "$path" ]]; then
        echo "Creating directory: $path"
        mkdir -p "$path"
    fi
done

docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p "${PORT:-7777}:7777/udp" \
  -p "${QUERY_PORT}:${QUERY_PORT}/udp" \
  -v "$(realpath "$GAME_PATH"):/home/steam/game" \
  -v "$(realpath "$SAVES_PATH"):/home/steam/game/AbioticFactor/Saved/SaveGames/Server" \
  -v "$(realpath "$WINE_PATH"):/home/steam/.wine" \
  -e "USER_UID=${PUID:-1000}" \
  -e "USER_GID=${PGID:-1000}" \
  -e "ServerPassword=${SERVER_PASSWORD}" \
  -e "SteamServerName=${STEAM_SERVER_NAME}" \
  -e "NoAsyncLoadingThread=${NO_ASYNC_LOADING_THREAD:-true}" \
  -e "UsePerfThreads=${USE_PERF_THREADS:-true}" \
  -e "MaxServerPlayers=${MAX_SERVER_PLAYERS:-3}" \
  -e "UseQueryPort=${USE_QUERY_PORT:-true}" \
  -e "QueryPort=${QUERY_PORT}" \
  -e "WorldSaveName=${WORLD_SAVE_NAME:-Cascade}" \
  abiotic-ds-image:1.0
