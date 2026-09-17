docker-build:
	docker compose build --no-cache

docker-up:
	docker compose up -d

docker-down:
	docker compose down --remove-orphans

docker-start:
	docker compose start

docker-stop:
	docker compose stop

docker-rebuild: docker-build docker-up

update-game:
	docker compose run --rm -it abiotic-server /usr/local/bin/updateGame.sh

run-terminal:
	docker compose run --rm -it abiotic-server bash

build-image:
	docker build -t abiotic-ds-image:1.0 ./docker
