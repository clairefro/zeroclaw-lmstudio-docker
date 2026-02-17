# ZeroClaw with LM Studio in Docker

## Quickstart

start

```sh
docker compose up -d --build
```

onboard zeroclaw

```sh
docker exec -it zeroclaw zeroclaw onboard --interactive
```

after onboarding, pair the terminal (inside container)

```sh
docker exec zeroclaw curl -X POST http://127.0.0.1:8080/pair \
     -H "X-Pairing-Code: <pairing code from onboarding>"
```

interact (zeroclaw agent cli)

```sh
docker exec -it zeroclaw zeroclaw agent --config /root/.config/zeroclaw/config.toml
```

## other

view zeroclaw config

```sh
docker exec zeroclaw cat /root/.config/zeroclaw/config.toml
```

interact (bash)

```sh
docker exec -it zeroclaw bash
```

lm studio connectivity test

```sh
# mac/windows
docker exec zeroclaw curl -s http://host.docker.internal:1234/v1/models

# linux uses different host name w/ docker
# curl http://172.17.0.1:1234/v1/models
```

docker logs

```sh
docker logs zeroclaw
```

## zeroclaw status

```sh
docker exec zeroclaw zeroclaw status
```

### down and up

```sh
docker compose down && docker compose up -d
```

## stop

```sh
docker stop zeroclaw
```

or stop and remove volumes

```sh
docker compose down -v
```

## start

```sh
docker start zeroclaw
```

## troubleshooting

If you are on Linux, host.docker.internal doesn't always work out of the box. You must tell Docker what that address means by adding a flag to your run command:
--add-host=host.docker.internal:host-gateway

zeroclaw doctor

```sh
docker exec -it zeroclaw zeroclaw doctor
```
