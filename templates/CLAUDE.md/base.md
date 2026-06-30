# Project Context

<!-- Replace this section with your project's name, purpose, and key facts Claude needs to know -->
<!-- Example: "This is a Next.js e-commerce app using Stripe and Supabase. The prod DB is read-only." -->

---

## Operating Principles

- Prefer editing existing files over creating new ones
- No comments explaining what code does — only WHY when non-obvious
- No error handling for scenarios that can't happen
- No features beyond what the task requires
- Verify before claiming completion — run tests, check the actual output

## Delegation Rules

- For multi-file changes or refactors: break into discrete steps, verify each
- For external APIs or SDKs: check docs before implementing (don't rely on training data)
- For anything touching auth, payments, or PII: flag before proceeding

## Verification Protocol

Before marking any task complete:
1. Run relevant tests and read the output
2. Check for type errors (`tsc --noEmit` or equivalent)
3. Confirm the change works in the actual running app, not just in theory

## Common Permissions

<!-- Paste your frequently needed tool permissions here so Claude doesn't prompt repeatedly -->
<!-- Example: Bash(npm run *), Bash(git *), Read(**), Edit(**) -->

## Project-Specific Rules

<!-- Add rules specific to this project -->
<!-- Examples:
- Never commit directly to main — always use a feature branch
- The .env file is at project root and must never be committed
- Run `npm run dev` on port 3000; do not change the port
- Database migrations live in db/migrations/ and run via `npm run migrate`
-->
