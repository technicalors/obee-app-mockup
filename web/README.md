# Obee Vben Web

This is the new Obee frontend foundation based on Vben Admin.

`web` is not a Git submodule. It is a normal source directory inside the Obee repository.

## Development

```bash
cd web
corepack enable
pnpm install
pnpm dev
```

The Obee Ant Design Vue app runs from `apps/workspace`. After creating its local `.env` from the example, the dev port is `5666`, so it does not replace the current Obee React frontend on port `5125`.

`apps/web-antd`, `apps/backend-mock`, the root `src` directory, `turbo.json`, and `scripts/turbo-run` have been removed. `apps/workspace` is the only active application entry.

Do not run `pnpm build` in this repository unless the project rules change.

## Source Ownership

New Obee business code should live under `apps/workspace/src`, including:

- `apps/workspace/src/api`
- `apps/workspace/src/assets`
- `apps/workspace/src/components`
- `apps/workspace/src/layouts`
- `apps/workspace/src/router`
- `apps/workspace/src/store`
- `apps/workspace/src/views`

Vben-origin or framework-sensitive code is protected by `.vben-protected-paths`. Do not modify protected paths unless the task is explicitly an upstream sync or framework-level change.

Obee-maintained workspace overrides are listed in `.vben-owned-overrides`. Upstream syncs must preserve these files and merge them manually.

## Upstream Baseline

- Source: `https://github.com/vbenjs/vue-vben-admin`
- Branch: `main`
- Baseline commit: `f23c9f5e197219b6184a86c3200969efaea803ec`
- Active downstream app: `apps/workspace` (`@obee/workspace`)
- Upstream-managed scope: shared packages, internal tooling, scripts, and root workspace config
- Import date: `2026-06-08`
- Import style: copied into `web`, no submodule

## Local Env

The app env example is tracked at `apps/workspace/.env.example`.

For a fresh checkout:

```bash
cp apps/workspace/.env.example apps/workspace/.env
```
