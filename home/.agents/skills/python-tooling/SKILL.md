---
name: python-tooling
description: Use when choosing Python tooling — package managers (uv, pip, venv), environments, linters, formatters, and test/build tools (ruff). Apply when installing, adding, or running any Python tool.
---

# Python tooling preferences

Preference order for all Python tooling decisions.

## Package / environment management

1. **uv** — preferred for everything: dependency management, virtualenvs, and tool running (`uv run`, `uv add`, `uv sync`, `uv tool`).
2. **Ruff** — preferred linter/formatter (`ruff check`, `ruff format`).
3. If a project can be used with uv/ruff, use them. Prefer adapting the workflow to uv over pulling in other tooling.

## pip and non-uv tooling

- Avoid non-venv `pip` — never `pip install` into a global interpreter.
- If `pip` must be used, unless explicitly told otherwise, use it inside a virtualenv (`uv venv` or `python -m venv`), then `pip install` into that venv.
- Same rule applies for all non-uv tooling: if you have to use something other than uv (e.g. pipenv, poetry, conda), still work inside a venv rather than the global interpreter.
