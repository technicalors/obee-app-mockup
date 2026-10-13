# Vben Web Development

These instructions apply to all work under `web/`.

## Required Skills

- Always use the `vben-upstream` skill before changing Vben-origin code, workspace tooling, or application structure.
- Always use the `vben` skill for routes, menus, access control, components, API integration, preferences, themes, and localization.
- Always use the `pinia` skill when creating or editing stores.

## Application Ownership

- `apps/workspace/**` is the Obee application and the only app used for normal Obee product development.
- `packages/**`, `internal/**`, `scripts/**`, and protected root workspace/tooling files remain upstream-managed or framework-sensitive.
- `apps/web-antd/**`, `apps/backend-mock/**`, `scripts/turbo-run/**`, `turbo.json`, and the root `src/**` directory have been removed from the active workspace. Do not reintroduce them without an explicit structural task.

## Upstream Discipline

- Prefer consuming and composing existing capabilities from `packages/**` and `internal/**` before creating new workspace-level primitives or duplicate helpers.
- Prefer extending or overriding behavior in `workspace` over modifying shared Vben packages.
- Do not modify `packages/**` or `internal/**` during normal Obee feature work unless the user explicitly asks for a framework-level or upstream-managed change.
- Do not copy shared package code into `workspace` merely to customize it.
- During an upstream sync, update shared upstream-managed paths first, then port compatible changes into `workspace` deliberately. Never overwrite `workspace`.
- Preserve every path listed in `.vben-owned-overrides` during upstream syncs. Merge upstream changes into those files manually without removing Obee workspace, CI, spelling, or dependency-check configuration.
- Treat `.vben-owned-overrides` as the source of truth for Obee-owned root workspace, package-manager, runtime, browser, test, lint, and formatting policy.
- Record upstream baseline and sync decisions in `docs/web_plan.md`.
- Never create `web/.git`, `.gitmodules`, or a nested Git repository.
- Never run `pnpm build`.

## Vben Application Conventions

- Run the Obee app with `pnpm dev` from `web/`.
- Use `#/*` for imports inside `apps/workspace/src/**`.
- Keep route modules in `apps/workspace/src/router/routes/modules/**`.
- Keep app APIs in `apps/workspace/src/api/**` and follow Vben request-client patterns.
- Before building a new component, composable, utility, or UI pattern in `workspace`, check whether an existing option in `packages/**` or `internal/**` already fits the need and reuse it when practical.
- Validate unknown data with Zod only. Do not invent mini parsers such as `parseString`, `readString`, or similar field-reading helpers.
- Put app-level stores in `apps/workspace/src/store/**`.
- Prefer Vben components, layouts, access helpers, preferences, and utilities before introducing custom equivalents.
- Do not route new work through deleted legacy paths or recreate the removed Turbo workflow.

## Obee Auth State

- Preserve the existing cookie-session authentication flow and its session marker integration with Vben stores.
- Do not introduce app-level names containing `obee-`, `obee_`, `obee `, `vben-`, `vben_`, or `vben ` merely to distinguish duplicate session, user, auth, API, adapter, or state representations. Use neutral domain names such as `SESSION_MARKER`, `toUserInfo`, and `user`.
- Framework-owned names such as `@vben/*`, `VbenForm`, and `web`, plus legitimate Obee product names, are not covered by the bridge-name ban.

## Pinia

- All new app-level stores must be Setup Stores using the Composition API.
- Use `ref()` or `reactive()` for state, `computed()` for getters, and named functions for actions.
- Every Setup Store must expose a manual `$reset()` function.
- Every store file must include `acceptHMRUpdate` handling.
- Return every state value, getter, and action that Pinia must track.
- Persist only explicitly selected fields with `persist.pick`.
- Do not create new Option Stores. Existing upstream Option Stores may retain their current style unless they are intentionally migrated.

## Validation

After any change under `web/`, run:

```bash
cd web
pnpm check
```

For changes to `workspace`, also run:

```bash
BASE_REF=origin/master ../scripts/guard-vben-protected-paths.sh
```

Start `pnpm dev` only when runtime verification is needed, and stop it after confirmation.
