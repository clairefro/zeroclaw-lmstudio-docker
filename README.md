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

NOTE FOR LM STUDIO: for provider, choose "custom with OpenAI bindings", use your local model's server url. on host machine windows/mac: `http://host.docker.internal:1234/v1` / linux: `http://172.17.0.1:1234/v1`. be sure to set API key as some non-empty string (ex: `lm-studio`)

- ensure LLM local server is ON
- ensure CORS enabled
- ensure local network access enabled

interact (zeroclaw agent cli)

```sh
docker exec -it zeroclaw zeroclaw agent
```

## other

view zeroclaw config

```sh
docker exec zeroclaw cat /root/.config/zeroclaw/config.toml
```

interact (bash)

```sh
docker exec -it -w /root/.zeroclaw zeroclaw bash
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

### local model hanging?

If you succesfulyl connect to local model but response is hanging, update config.toml (in mounted `./zeroclaw_data/config.toml`)

Add this provider info to the bottom to

```toml
[provider]
# Match your default_provider string exactly
name = "custom:http://host.docker.internal:1234/v1"
api_key = "lm-studio"
# ENSURE THIS IS INDENTED UNDER [provider]
stream = false
timeout_seconds = 120  # Give it extra time for local inference
```

or if it's a context window issue, try upping your local llm's context window, or compacting the agent's activities:

```sh
# Stop the agent
docker compose down

# Delete the persistent memory and session data
# (This keeps your config but deletes the bloated chat history)
rm -rf ./workspace/memory/*
rm -rf ./workspace/sessions/*

```

and add in config.toml

```toml
[agent]
# Reduce history to keep the 'Context Shift' from happening
max_history_messages = 10
compact_context = true # Tell ZeroClaw to summarize old stuff

[memory]
# Disable the response cache for now to ensure fresh responses
response_cache_enabled = false
```

```sh
# Restart
docker compose up -d
```
