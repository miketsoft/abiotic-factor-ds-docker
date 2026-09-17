FROM scottyhardy/docker-wine:stable-11.0

ENV WINEDEBUG=-all

# Save the original docker-wine entrypoint
RUN cp /usr/bin/entrypoint /usr/bin/docker-wine-entrypoint

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/updateGame.sh /usr/local/bin/updateGame.sh
COPY scripts/startGame.sh /usr/local/bin/startGame.sh

RUN chmod +x \
    /usr/local/bin/entrypoint.sh \
    /usr/local/bin/updateGame.sh \
    /usr/local/bin/startGame.sh

RUN set -x && \
	dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
      lib32stdc++6 \
      lib32gcc-s1 \
      ca-certificates \
      curl && \
	rm -rf /var/lib/apt/lists/*

# The username and home directory are fixed in entrypoint.sh
WORKDIR /home/steam

RUN HOME_DIR="/home/steam" && \
    STEAMCMD_DIR="${HOME_DIR}/steamcmd" && \
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

ENV PATH="/home/steam/steamcmd:${PATH}"

EXPOSE 7777/udp

VOLUME /home/steam/game/AbioticFactor/Saved/SaveGames/Server

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/startGame.sh"]
