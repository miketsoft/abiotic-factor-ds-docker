FROM scottyhardy/docker-wine:latest

ARG HOME_DIR=/home/steam

ENV DEBIAN_FRONTEND=noninteractive
ENV WINEDEBUG=-all

# Save original docker-wine entrypoint
RUN cp /usr/bin/entrypoint /usr/bin/docker-wine-entrypoint

COPY entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

RUN set -x && \
	dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests lib32stdc++6 lib32gcc-s1 ca-certificates curl && \
	rm -rf /var/lib/apt/lists/*

WORKDIR ${HOME_DIR}

RUN STEAMCMD_DIR="${HOME_DIR}/steamcmd" && \
    mkdir -p "${STEAMCMD_DIR}" "${HOME_DIR}/.steam/sdk32" "${HOME_DIR}/.steam/sdk64" && \
    curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C "${STEAMCMD_DIR}" && \
	"${STEAMCMD_DIR}/steamcmd.sh" +quit && \
	ln -s "${STEAMCMD_DIR}/linux32/steamclient.so" "${STEAMCMD_DIR}/steamservice.so" && \
    ln -s "${STEAMCMD_DIR}/linux32/steamclient.so" "${HOME_DIR}/.steam/sdk32/steamclient.so" && \
	ln -s "${STEAMCMD_DIR}/linux64/steamclient.so" "${HOME_DIR}/.steam/sdk64/steamclient.so" && \
	ln -s "${STEAMCMD_DIR}/linux32/steamcmd" "${STEAMCMD_DIR}/linux32/steam" && \
	ln -s "${STEAMCMD_DIR}/linux64/steamcmd" "${STEAMCMD_DIR}/linux64/steam" && \
	ln -s "${STEAMCMD_DIR}/steamcmd.sh" "${STEAMCMD_DIR}/steam.sh" && \
    ln -s "${STEAMCMD_DIR}/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so"

ENV PATH="${HOME_DIR}/steamcmd:${PATH}"
