# Project Context

<!-- Go service/API project — replace with your specifics -->

---

## Operating Principles

- Prefer editing existing files over creating new ones
- No comments explaining what code does — only WHY when non-obvious
- Handle errors explicitly — never swallow them with `_`
- No features beyond what the task requires
- Verify before claiming completion — run tests and build

## Stack & Commands

```bash
go run ./cmd/server        # Start dev server
go build ./...             # Build all packages
go test ./...              # Run all tests
go test ./... -race        # Test with race detector
go vet ./...               # Static analysis
golangci-lint run          # Lint (if installed)
```

## Go-Specific Rules

- Always check and handle errors — no `_ = err`
- Prefer interfaces over concrete types in function signatures
- Table-driven tests with `t.Run` for readability
- Use `context.Context` as the first argument for any function that does I/O
- Package names: short, lowercase, no underscores
- `go.mod` and `go.sum` are always committed

## Project Structure

```
cmd/
  server/       # Main entrypoint
internal/
  handler/      # HTTP handlers
  service/      # Business logic
  store/        # Data access layer
  model/        # Domain types
pkg/            # Exported packages (reusable)
```

## Verification Protocol

Before marking any task complete:
1. `go build ./...` — zero build errors
2. `go test ./... -race` — all tests pass, no race conditions
3. `go vet ./...` — zero vet errors
4. Test the actual endpoint

## Delegation Rules

- External packages: check if stdlib already covers the need first
- DB changes: always create migration files
- Concurrency code: flag for extra review — use race detector
