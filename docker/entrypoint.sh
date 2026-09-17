#!/bin/bash
set -euo pipefail

# Internal container user configuration.
# Do not expose these variables through docker-compose.yml.
export USER_NAME="steam"
export USER_HOME="/home/steam"

exec /usr/bin/docker-wine-entrypoint "$@"
