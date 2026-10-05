# jQuery template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, deploy workflows, `compose.yaml`) with a static multi-page site in plain HTML/CSS with jQuery 4 for the DOM (events, delegated handlers, `$.getJSON`) laid on top.

Listens on `0.0.0.0:$PORT` (default `8080`) and serves at the root (`/`) of its own hostname
(`https://<hash>.<FLEET_APP_DOMAIN>/`); the health check hits `/`. In the container: nginx serving `dist/`.

## Origin

    hand-written (jQuery has no project generator); jQuery installed from npm: npm install jquery

Generated 2026-10-05 with jQuery 4.0.0 (host Node v22.12.0 / npm 10.9.0).

## Run it

### On the fleet

The fleet clones the repo, injects `PORT` (and the workspace's `DATABASE_URL`, `REDIS_URL`, ...) and runs
`bin/run`, which uses the docker runtime from `fleet.conf`: `docker compose build`, then `docker compose up --remove-orphans` in the foreground.

### With docker

    PORT=8080 bin/run                  # what the fleet does
    docker compose up --build        # or plain compose

### Without docker

`FLEET_RUNTIME=process bin/run` runs the plain commands from `fleet.conf`:

| step | command |
|---|---|
| install | `npm install` |
| build | `npm run build` |
| start | `npx http-server dist -a 0.0.0.0 -p $PORT -c-1` |

    ./bin/run       # install, build, start in the foreground
    ./bin/start     # start from existing build artifacts
    ./bin/restart   # rebuild and restart
    ./bin/stop      # stop whatever holds the port

See `docs/fleet-lifecycle.md` for the full contract.

## Deviations from the generator output

- Layout: pages and assets under `public/`; `npm run build` (`scripts/build.mjs`, no dependencies) copies them to `dist/` together with `node_modules/jquery/dist/jquery.min.js` -> `dist/vendor/`, so the jQuery version is pinned by `package-lock.json` and nothing loads from a CDN.
- No SPA fallback in nginx: it is a multi-page site, so a missing file is a real 404.
- Without docker, `http-server` (a devDependency) serves `dist/`.
- Added the fleet files: `bin/` (lifecycle scripts), `fleet.conf`, `Dockerfile`, `compose.yaml`, `.dockerignore`, `.env.example`, `.github/workflows/`, `docs/fleet-lifecycle.md`; fleet entries (`.fleet/`, `*.log`, ...) prepended to `.gitignore`.

## Verified

**Not yet verified in docker.** On 2026-10-05 the shared docker host's disk stayed at 0-2 GB free for over 3 hours (held by other workloads), so the image was never built; `verify.sh` / `docker compose run` must still be run before this is trusted. `migrate.py audit`: READY. Without docker: `npm install && npm run build` produced `dist/` and `http-server` answered 200 on `/` and served `/vendor/jquery.min.js` (jQuery 4.0.0).
