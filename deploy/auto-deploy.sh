#!/bin/bash

# eventflow - Auto Deployment Script
# Polls the GitHub repository for changes on the deploy branch and, when a new
# commit appears, pulls it and rebuilds the docker compose stack.
#
# Usage: ./auto-deploy.sh [--force]
#   --force: Deploy even if no new commits are detected.

set -e

WORK_DIR="/opt/eventflow"
LOG_FILE="$WORK_DIR/deploy.log"
LOCK_FILE="$WORK_DIR/deploy.lock"
ENV_FILE="$WORK_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "$(date): Error: .env file not found at $ENV_FILE" >> "$LOG_FILE"
    exit 1
fi

GITHUB_REPO=${GITHUB_REPO:-"https://github.com/luizdalcico/eventflow.git"}
GITHUB_BRANCH=${GITHUB_BRANCH:-"main"}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "❌ ERROR: $1"
    exit 1
}

check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid
        lock_pid=$(cat "$LOCK_FILE")
        if kill -0 "$lock_pid" 2>/dev/null; then
            log "Deployment already running (PID: $lock_pid)"
            exit 0
        else
            log "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi
}

create_lock() { echo $$ > "$LOCK_FILE"; }
remove_lock() { rm -f "$LOCK_FILE"; }
trap remove_lock EXIT

get_remote_commit() { git ls-remote "$GITHUB_REPO" "$GITHUB_BRANCH" | cut -f1; }
get_local_commit() {
    if [ -d "$WORK_DIR/.git" ]; then
        cd "$WORK_DIR" && git rev-parse HEAD 2>/dev/null || echo ""
    else
        echo ""
    fi
}

update_repository() {
    log "Updating repository..."
    cd "$WORK_DIR"
    # Preserve the server-only .env across the hard reset.
    [ -f ".env" ] && cp .env /tmp/eventflow.env.backup
    git fetch origin || error_exit "git fetch failed"
    git reset --hard "origin/$GITHUB_BRANCH" || error_exit "git reset failed"
    git clean -fd -e .env -e deploy.log || error_exit "git clean failed"
    [ -f "/tmp/eventflow.env.backup" ] && mv /tmp/eventflow.env.backup .env
}

deploy_application() {
    log "Building and starting containers..."
    cd "$WORK_DIR"
    docker compose up --build -d || error_exit "docker compose up failed"
    docker image prune -f >/dev/null 2>&1 || true
    sleep 20
    if docker compose ps web | grep -q "Up\|running"; then
        log "✅ Deployment successful (db:prepare runs in the container entrypoint)."
    else
        error_exit "web service not running after deploy"
    fi
}

main() {
    local force_deploy=false
    [ "${1:-}" = "--force" ] && force_deploy=true

    log "🔍 Checking for updates..."
    check_lock
    create_lock

    local remote_commit local_commit
    remote_commit=$(get_remote_commit)
    local_commit=$(get_local_commit)
    [ -z "$remote_commit" ] && error_exit "could not read remote commit"

    log "Remote: $remote_commit | Local: $local_commit"

    if [ "$remote_commit" != "$local_commit" ]; then
        log "🔄 New commit detected, deploying..."
        update_repository
        deploy_application
    elif [ "$force_deploy" = true ]; then
        log "🚀 Force deploy requested..."
        deploy_application
    else
        log "✅ No updates needed"
    fi
}

mkdir -p "$WORK_DIR"
main "$@"
