# our-docker-setup

The backend for Our Amp on one machine: a docker compose file with

| Service | Image | Role |
|---|---|---|
| `postgres` | `postgres:18.6-trixie` | Two databases: `app` and `rivet` (the engine's) |
| `rivet-engine` | `rivetdev/engine:full-2.3.30` | Self-hosted Rivet engine, stored in Postgres |
| `app` | built from `Dockerfile` | SvelteKit server (Node 26); the Rivet actors join it in M1 |
| `alloy` | `grafana/alloy:v1.21.2` | OTLP collector on 4318, bearer token required |
| `pgadmin` | `dpage/pgadmin4:9.18.0` | Web UI for Postgres at `127.0.0.1:5050`; never public |

Every published port is bound to `127.0.0.1`. On the VM, Tailscale Funnel makes them public:
443 → 3000 (app), 8443 → 4318 (Alloy), 10000 → 3001 (portal, once it exists).
pgAdmin stays private: on the VM, `tailscale serve --bg --https=5050 5050` opens it to your tailnet only.

## Run it locally

```sh
cp .env.example .env   # fill in the random strings
docker compose up -d --build
curl localhost:3000/healthz   # {"ok":true,"checks":{"postgres":"ok","rivet":"ok"}}
```

Stop with `docker compose down` (add `-v` to delete the Postgres volume).

## Code

pnpm workspace: `apps/web` (SvelteKit 3, adapter-node) and `packages/db`.
`pnpm install`, `pnpm dev`, `pnpm check`, `pnpm build`.

## Deploys

`.github/workflows/ci.yml` runs checks and builds the image on every push and pull request.
On `main` it pushes the image to `ghcr.io/ozzyozbourne/ouramp-app` (public, tagged with the
commit SHA and `latest`) and deploys, once these repository settings exist:

| Kind | Name | Value |
|---|---|---|
| variable | `VM_HOST`, `VM_SSH_USER` | the VM's tailnet name and SSH user |
| secret | `TS_OAUTH_CLIENT_ID`, `TS_OAUTH_SECRET` | Tailscale OAuth client allowed to create `tag:ci` nodes |

The deploy joins the tailnet as `tag:ci`, copies the compose files to `~/ouramp` on the VM over
Tailscale SSH and runs `docker compose pull && docker compose up -d`. The VM keeps its
own `.env`; it is never in this repo.
