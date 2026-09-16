#!/usr/bin/env bash
set -e

# Internal container user configuration.
# Do not expose these through docker-compose.yml.
export USER_NAME="steam"
export USER_HOME="/home/steam"

exec /usr/bin/docker-wine-entrypoint "$@"
