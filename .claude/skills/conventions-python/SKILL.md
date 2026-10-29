---
name: conventions-python
description: Python default conventions — uv and pyproject.toml, Ruff, strict typing, Pydantic at boundaries, pytest, logging and resource handling. Use when writing Python code, configuring pyproject.toml, or adding Python tests.
---

The repo's own tooling and configuration win over these.

## Project

- **`uv`** for environments, dependencies and the Python version (`.python-version`). Commit the lockfile. Never install into the system Python.
- **One `pyproject.toml`** for metadata and tool configuration. Use a `src/` layout for packages.
- **Ruff** for both linting and formatting.

## Code

- **Type hints everywhere**, checked with `mypy --strict` or `pyright` in CI.
- **Validate at boundaries with Pydantic** (HTTP, files, env via `pydantic-settings`). Inside, use `dataclasses`. No untyped dicts crossing module boundaries.
- **`pathlib.Path`** for paths, and **context managers** for anything that needs cleanup.
- **`logging`**, never `print`, in library or service code.
- No mutable default arguments. No bare `except:`. Catch specific exceptions, and re-raise with context (`raise … from err`).

## Tests

- **pytest**, with fixtures for setup and `tmp_path` for files. Apply the rules in `conventions-testing`.
