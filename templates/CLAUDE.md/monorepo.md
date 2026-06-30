# Project Context

<!-- Monorepo project — replace with your specifics -->
<!-- Tools: npm workspaces / pnpm workspaces / Turborepo / Nx -->

---

## Operating Principles

- Prefer editing existing files over creating new ones
- No comments explaining what code does — only WHY when non-obvious
- No features beyond what the task requires
- Changes to shared packages affect all consumers — verify downstream impact
- Verify before claiming completion — run tests in affected packages

## Monorepo Structure

```
apps/
  web/          # Frontend app
  api/          # Backend service
  admin/        # Admin panel
packages/
  ui/           # Shared UI components
  shared/       # Shared types and utilities
  config/       # Shared configs (tsconfig, eslint, etc.)
```

## Commands

```bash
# Run from root
npm run dev              # Start all apps in dev mode
npm run build            # Build all packages and apps
npm run test             # Run tests in all packages
npm run lint             # Lint all packages

# Run for a specific package
npm run dev --workspace=apps/web
npm run test --workspace=packages/ui
```

## Monorepo-Specific Rules

- Shared types belong in `packages/shared/` — never duplicate across apps
- UI components belong in `packages/ui/` if used by >1 app
- Never add a dependency to `apps/*` if it belongs in `packages/*`
- Workspace protocol for internal deps: `"@myorg/ui": "workspace:*"`
- Changes to `packages/` require testing all consuming `apps/`

## Verification Protocol

Before marking any task complete:
1. `npm run build` from root — all packages build
2. `npm run test` — all tests pass
3. If you changed a shared package, test at least one consuming app
4. Check for circular dependencies

## Delegation Rules

- Cross-package refactors: map all consumers first before making changes
- Breaking changes to shared packages: flag and plan migration path
