# ZeroClaw with LM Studio in Docker

Run ZeroClaw agent with local models (LM Studio) in Docker container, with host-mounted volumes for easy access and transparency.

NOTE: for Ollama, use ZeroClaw's Ollama provider option in onboarding wizard

### Recommended Models for ZeroClaw (2026)

| Model Name            | Parameter Size | Architecture | Best Use Case                                                                           | VRAM / RAM  |
| :-------------------- | :------------- | :----------- | :-------------------------------------------------------------------------------------- | :---------- |
| **Mistral Small 3.2** | 24B            | Dense        | **Most Reliable.** The current gold standard for local tool use. Zero formatting leaks. | 16GB - 24GB |
| **Qwen3-8B-Instruct** | 8B             | Dense        | **Fastest.** High instruction following with a massive context window (131k).           | 8GB - 12GB  |
| **Llama 4-8B**        | 8B             | Dense        | **Daily Driver.** Optimized for agentic execution and multi-step reasoning.             | 8GB         |
| **DeepSeek-V3.2-Exp** | 7B-14B         | MoE          | **Coding & Logic.** Best for complex shell commands and repo browsing.                  | 10GB - 16GB |
| **MiMo-V2-Flash**     | 15B (Active)   | MoE          | **Efficiency.** Ultra-fast output speed (60+ tps) for snappy terminal work.             | 12GB        |

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
docker exec zeroclaw cat /root/.zeroclaw/config.toml

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

## down and up

```sh
docker compose down && docker compose up -d
```

or restart

```sh
docker compose restart zeroclaw
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

or compose

```sh
docker compose up -d
```

## force config reload

```sh
docker compose up -d --force-recreate
```

## troubleshooting

If you are on Linux, host.docker.internal doesn't always work out of the box. You must tell Docker what that address means by adding a flag to your run command:
--add-host=host.docker.internal:host-gateway

zeroclaw doctor

```sh
docker exec -it zeroclaw zeroclaw doctor
```

### local model hanging?

If you successfully connect to local model but response is hanging, update config.toml (in mounted `./zeroclaw_data/config.toml`)

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

and add/edit in config.toml

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

### getting Harmony-style respones?

example:

```
<|channel|>commentary to=tool_result <|constrain|>json<|message|>We need to wrap in <tool_call>.<|channel|>commentary to=tool_result <|constrain|>json<|message|>{"name":"shell","arguments":{"command":"curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"},"approved":false}
```

your local model might be using Harmony-style formatting. force openai still responses by updating config.toml

```toml
[provider]
name = "custom:http://host.docker.internal:1234/v1"
api_key = "lm-studio"
# Tell ZeroClaw to handle Harmony-style formatting
# (Note: This depends on your specific ZeroClaw binary version)
format = "openai-compatible"
strip_special_tokens = true
```

or try adding this in IDENTITY.md

```markdown
# HARMONY PROTOCOL RULES

- NEVER output raw tokens like <|channel|>, <|message|>, or <|constrain|>.
- Your response to the user MUST be plain text only.
- All tool calls MUST be standard JSON wrapped in <tool_call> tags.
- Do not announce your internal planning to the user.
```

or in LM Studio:

1. Click Settings (the Gear icon ⚙️ in the bottom-left sidebar).
1. Select Developer from the sub-menu.
1. Scroll down to the bottom to find the section for REST API.
1. Toggle ON: "When applicable, separate reasoning_content and content in API responses".

and Configure Your Model's Stop Strings

- Start String to <|channel|>analysis<|message|>.
- End String to <|end|>.
- Ensure Reasoning Section Parsing is toggled ON.
