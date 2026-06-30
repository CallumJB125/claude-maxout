# Project Context

<!-- Python API project — replace with your specifics -->
<!-- Stack: FastAPI/Flask/Django + PostgreSQL/SQLite -->

---

## Operating Principles

- Prefer editing existing files over creating new ones
- No comments explaining what code does — only WHY when non-obvious
- No error handling for scenarios that can't happen
- No features beyond what the task requires
- Verify before claiming completion — run tests, check actual output

## Stack & Commands

```bash
python -m uvicorn main:app --reload   # Start FastAPI dev server
# OR
python manage.py runserver            # Django
# OR
flask run                             # Flask

pytest                    # Run tests
pytest -x                 # Stop on first failure
ruff check .              # Lint
mypy .                    # Type check
alembic upgrade head      # Run migrations (if using SQLAlchemy/Alembic)
```

## Python-Specific Rules

- Virtual environment: always activated before running commands (`.venv/` or `venv/`)
- Package manager: `pip` with `requirements.txt` OR `poetry` with `pyproject.toml`
- Never use mutable default arguments in function signatures
- Type hints on all public function signatures
- Prefer `pathlib.Path` over `os.path`
- `python-dotenv` for environment variables — never hardcode secrets

## Project Structure

```
app/
  api/          # Route handlers / views
  models/       # Data models / ORM
  services/     # Business logic
  schemas/      # Pydantic schemas / serializers
tests/
  unit/
  integration/
```

## Verification Protocol

Before marking any task complete:
1. `pytest` — all tests pass
2. `mypy .` — zero type errors (if mypy configured)
3. `ruff check .` — zero lint errors
4. Test the actual endpoint with curl or httpie

## Delegation Rules

- External APIs: check current docs before implementing
- DB schema changes: always create a migration, never modify tables directly
- Auth/permissions: always flag before proceeding
