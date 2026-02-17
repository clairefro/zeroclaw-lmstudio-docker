# Stage 1: Build the binary
FROM rust:1.80-slim as builder

WORKDIR /usr/src/zeroclaw
RUN apt-get update && apt-get install -y pkg-config libssl-dev git && rm -rf /var/lib/apt/lists/*

# Clone and build ZeroClaw
RUN git clone https://github.com/openagen/zeroclaw.git .
RUN cargo build --release

# Stage 2: Final lightweight image
FROM debian:bookworm-slim

WORKDIR /app
RUN apt-get update && apt-get install -y libssl3 ca-certificates curl && rm -rf /var/lib/apt/lists/*

# Copy binary and set permissions
COPY --from=builder /usr/src/zeroclaw/target/release/zeroclaw /usr/local/bin/zeroclaw

# Ensure config and skills directories exist
RUN mkdir -p /root/.zeroclaw /root/.zeroclaw/workspace/skills /root/.config/zeroclaw

# Copy default config.toml into image
COPY config.toml /root/.zeroclaw/config.toml

EXPOSE 8080

# Start as a daemon by default
CMD ["zeroclaw", "daemon"]