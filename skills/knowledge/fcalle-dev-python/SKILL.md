---
name: fcalle-dev-python
description: Python conventions — type hints, Pydantic, Ruff, uv/poetry, pathlib, logging, context managers. Use when writing Python code, configuring pyproject.toml, or reviewing Python files.
---

## Python

- **Type hints everywhere.** `mypy --strict` or `pyright` in CI.
- **Pydantic** (or `attrs`/`dataclasses`) for data shapes; no untyped dicts crossing module boundaries.
- **Ruff** for lint + format (replaces `flake8`, `isort`, `black` for new projects).
- **`uv` or `poetry`** for dependency management; lockfile committed.
- **Virtualenv per project**, never install into system Python.
- **`pathlib.Path`** over `os.path` strings.
- **f-strings** over `.format()` and `%`.
- **`logging`** module, never `print` in library/service code.
- **Context managers** for any resource that needs cleanup.
