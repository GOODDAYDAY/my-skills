# Python Conventions

## Modularization

### Layer Structure

```
app/
├── main.py                # Single entry point
├── config/                # Settings, constants, shared definitions
├── core/                  # Orchestration — wires layers together
└── <layer>/               # One directory per responsibility
    ├── base.py            # ABC defining the layer's contract
    └── <impl>/            # One folder per implementation
        └── handler.py     # Concrete class, conventional export name
```

- Each layer is one responsibility: I/O, external API, background task, capability, etc.
- `base.py` defines the ABC contract; implementations live in their own subfolder
- Each implementation module exports one class with a **conventional name** (e.g., all implementations in the same layer export the same class name)
- Core discovers implementations via `importlib` + folder name — no registry, no match-case, no if-else chain

### Dependency Rules

```
main → core → all other layers (via callback injection)
```

- **Peer layers never import each other.** No horizontal dependencies
- **Passive layers never import core.** No reverse dependencies
- `config/` is the only package shared across all layers
- Core injects callbacks into passive layers; passive layers call them without knowing who's behind

### Adding a New Implementation

1. Create `<layer>/<name>/handler.py`
2. Export a class with the layer's conventional name, inheriting from `base.py`
3. Implement the abstract methods + a `validate()` for its own config
4. Done — core picks it up automatically. No wiring code, no config change

### Self-Validating Modules

- Each implementation validates its own config in `validate()` or `authenticate()`
- Config class only loads and displays values — it never knows which fields belong to which implementation
- Fail fast: validate at startup, not at first use

## Imports

```python
import os               # 1. stdlib
import logging

import requests         # 2. third-party

from myapp.utils import helper   # 3. local (absolute only)
```

- Blank line between each group
- Always absolute imports, never relative
- Inline imports only to break circular dependencies

## Type Hints

- Python 3.10+ union syntax: `str | None` instead of `Optional[str]`
- `TypeAlias` for complex callback signatures
- `@dataclass` for structured data; `@dataclass(frozen=True)` for immutable config

## Naming

| Kind | Style | Example |
|:---|:---|:---|
| Class | PascalCase | `UserService`, `BaseHandler` |
| Function / method | snake_case | `get_user`, `parse_response` |
| Private | `_` prefix | `_validate()`, `_cache` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRIES = 3` |
| Private constant | `_` + UPPER | `_DEFAULT_TIMEOUT = 30` |
| Logger | per-module | `logger = logging.getLogger("app.module")` |

## Logging

```python
logger = logging.getLogger("app.service.auth")

# Lazy formatting — never f-strings in log calls
logger.info("Loaded %d items", count)
logger.warning("Retry %d/%d for %s", attempt, max_retries, url)
logger.exception("Failed to process %s", item_id)
```

- One logger per module, named after module path
- `debug` for diagnostics, `info` for state changes, `warning` for non-fatal issues, `exception` for caught errors with traceback
- Truncate large values before logging; never log secrets

## Error Handling

```python
# Guard clause style — happy path reads top-down, errors at bottom
if primary_source:
    return primary_source

if fallback_source:
    return fallback_source

raise RuntimeError("No source available")
```

```python
# Collect all validation errors before raising
missing = []
if not config.api_key:
    missing.append("api_key")
if not config.base_url:
    missing.append("base_url")
if missing:
    raise ValueError(f"Missing required config: {', '.join(missing)}")
```

- Prefer standard exceptions (`ValueError`, `RuntimeError`, `EnvironmentError`)
- `except SpecificException` preferred; bare `except Exception` only with `logger.exception()`

## Async

```python
# async for all I/O
async def fetch_data(url: str) -> dict: ...

# Wrap blocking I/O in a thread
result = await asyncio.to_thread(blocking_func, arg)

# Context manager for HTTP sessions
async with aiohttp.ClientSession() as session:
    async with session.get(url) as resp:
        data = await resp.json()
```

## Docstrings

```python
"""Module purpose — one sentence explaining why this exists.

Optional detail on design, constraints, or non-obvious behavior.
"""
```

- Module-level docstring required
- Function/method docstrings only on ABCs or complex public APIs
- English only

## Path Handling

- Always `pathlib.Path`, never string concatenation
- `.resolve()` for absolute paths
- `.parent` chaining for relative navigation

## General Style

- Guard clauses over nested if-else
- No empty `__init__.py` — only when package-level init is needed
- Single `if __name__ == "__main__"` entry point, never in library modules
- `async/await` for all I/O-bound operations
