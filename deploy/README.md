# Deploy

eventflow runs on a bare-metal Ubuntu VPS (OVH, `158.69.223.24`) via Docker
Compose, behind a shared **Caddy** reverse proxy that terminates TLS.

```
Internet
  ├─ eventos.apisys.com.br          (DNS-only → real Let's Encrypt cert at Caddy)
  └─ github-pr-viewer.dalcico.com.br (Cloudflare Flexible → HTTP :80 at Caddy)
        │
      Caddy  :80 / :443   (/opt/proxy)
        ├─ eventos.apisys.com.br → eventflow-web:3000
        └─ github-pr-viewer...   → host.docker.internal:8081 (pr-viewer nginx)

  eventflow stack (/opt/eventflow): db (postgres:16) + web (Puma + Solid Queue in-process)
```

## Auto-deploy
A systemd timer (`eventflow-deploy.timer`) runs `deploy/auto-deploy.sh` every
5 minutes. When a new commit lands on `main` it pulls, runs
`docker compose up --build -d`, and the container entrypoint runs `db:prepare`.
**Push to `main` ⇒ live in ≤5 min.**

## Files
- `../docker-compose.yml` — app stack (db + web).
- `proxy-compose.yml` / `Caddyfile` — shared Caddy proxy (lives in `/opt/proxy`).
- `auto-deploy.sh` — git-poll + rebuild.
- `setup-server.sh` — one-time bootstrap.
- `eventflow-deploy.{service,timer}` — the 5-minute poll.

## Server `.env` (never committed, lives at `/opt/eventflow/.env`)
```
EVENTFLOW_DATABASE_PASSWORD=...
RAILS_MASTER_KEY=...                  # = config/master.key
GITHUB_REPO=https://github.com/luizdalcico/eventflow.git
GITHUB_BRANCH=main
```

## Manual ops
```
# follow deploy log
tail -f /opt/eventflow/deploy.log
# app logs
cd /opt/eventflow && docker compose logs -f web
# force a redeploy
/opt/eventflow/deploy/auto-deploy.sh --force
# rails console
cd /opt/eventflow && docker compose exec web ./bin/rails console
```
