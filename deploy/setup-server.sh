#!/bin/bash

# eventflow - One-time server bootstrap for an Ubuntu VPS that already has
# Docker installed (e.g. the OVH box shared with github_pr_viewer).
#
# It:
#   1. Brings up the shared Caddy reverse proxy (ports 80/443, automatic TLS).
#   2. Clones eventflow into /opt/eventflow and builds the stack.
#   3. Installs the systemd timer that polls main and auto-deploys.
#
# Requires /opt/eventflow/.env to already exist with:
#   EVENTFLOW_DATABASE_PASSWORD=...
#   RAILS_MASTER_KEY=...
#   GITHUB_REPO=https://github.com/luizdalcico/eventflow.git
#   GITHUB_BRANCH=main

set -e

APP_DIR="/opt/eventflow"
PROXY_DIR="/opt/proxy"
REPO="https://github.com/luizdalcico/eventflow.git"
BRANCH="main"

echo "🌐 Setting up shared Caddy proxy in $PROXY_DIR..."
sudo mkdir -p "$PROXY_DIR"
sudo chown "$USER:$USER" "$PROXY_DIR"
cp "$APP_DIR/deploy/proxy-compose.yml" "$PROXY_DIR/docker-compose.yml"
cp "$APP_DIR/deploy/Caddyfile" "$PROXY_DIR/Caddyfile"
( cd "$PROXY_DIR" && docker compose up -d )

echo "🚀 Building eventflow stack..."
( cd "$APP_DIR" && docker compose up --build -d )

echo "⚙️  Installing auto-deploy timer..."
sudo cp "$APP_DIR/deploy/eventflow-deploy.service" /etc/systemd/system/
sudo cp "$APP_DIR/deploy/eventflow-deploy.timer" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now eventflow-deploy.timer

echo "✅ Done. eventflow should be live at https://eventos.apisys.com.br"
echo "   Logs: tail -f $APP_DIR/deploy.log  |  docker compose -f $APP_DIR/docker-compose.yml logs -f web"
