# Project Context

<!-- Node.js fullstack project — replace with your specifics -->
<!-- Stack: Node + Express/Fastify backend, React/Vue/Svelte frontend -->

---

## Operating Principles

- Prefer editing existing files over creating new ones
- No comments explaining what code does — only WHY when non-obvious
- No error handling for scenarios that can't happen
- No features beyond what the task requires
- Verify before claiming completion — run tests, check actual output

## Stack & Commands

```bash
npm run dev        # Start dev server (frontend + backend)
npm run build      # Production build
npm test           # Run test suite
npm run lint       # Lint check
npm run typecheck  # TypeScript check (if applicable)
```

**Frontend:** runs on `localhost:3000` (or `localhost:5173` for Vite)
**Backend API:** runs on `localhost:3001` (adjust as needed)

## Project Structure

```
src/
  api/          # Backend routes and handlers
  components/   # Frontend components
  lib/          # Shared utilities
  types/        # TypeScript types (if applicable)
db/
  migrations/   # Database migration files
```

## Node-Specific Rules

- Package manager: `npm` (or replace with `yarn`/`pnpm`)
- Never install packages without checking if one already exists that does the job
- `node_modules/` and `.env` are never committed
- Environment variables live in `.env` — always use `process.env.VAR_NAME`
- For async code: prefer `async/await` over Promise chains

## Verification Protocol

Before marking any task complete:
1. `npm test` — all tests pass
2. `npm run typecheck` — zero type errors
3. `npm run lint` — zero lint errors
4. Test the actual feature in the browser at localhost

## Delegation Rules

- External APIs: check current docs via context7 MCP before implementing
- Auth changes: always flag before proceeding
- DB migrations: test on a copy before applying to the main DB
