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

## Methods as Documentation

### Core Philosophy

The essence of a service/orchestration class is **orchestration** — a public method calls a sequence of steps, where each step is a semantically clear private method. **Reading the public method should feel like reading a business flowchart — no comments needed to understand what the business is doing.**

This principle applies recursively: service calls service, handler calls handler — every layer should decompose complex logic into clearly-named private methods. The end result: **anyone opening any method sees a sequence of method calls, not a block of procedural code. Want details? Click into a method. Don't care? Skip it. Drill down layer by layer, each level is crystal clear.**

### Template

```python
class OrderService:
    """Orchestrates order creation workflow."""

    def __init__(self, repo: OrderRepository, payment: PaymentGateway, notifier: Notifier):
        self._repo = repo
        self._payment = payment
        self._notifier = notifier

    def create_order(self, data: OrderData) -> OrderResult:
        """Public method: reads like the business flow itself.
        Each line is a 'what', not a 'how'.
        """
        self._validate_order_data(data)
        self._ensure_no_duplicate(data.idempotency_key)
        enriched = self._enrich_with_defaults(data)
        order_id = self._persist_to_database(enriched)
        self._charge_payment(order_id, enriched.amount)
        self._notify_order_created(order_id)
        return self._build_result(order_id, enriched)

    # ══════════════════════════════════════════════
    #  Each private method corresponds to one step
    #  in the business flow. The method name IS the
    #  documentation. Click in to see details.
    # ══════════════════════════════════════════════

    def _validate_order_data(self, data: OrderData) -> None:
        missing = []
        if not data.customer_id:
            missing.append("customer_id")
        if not data.items:
            missing.append("items")
        if missing:
            raise ValueError(f"Missing required fields: {', '.join(missing)}")

    def _ensure_no_duplicate(self, idempotency_key: str) -> None:
        if self._repo.find_by_key(idempotency_key):
            raise ValueError(f"Duplicate order: {idempotency_key}")

    def _enrich_with_defaults(self, data: OrderData) -> OrderData:
        return OrderData(
            customer_id=data.customer_id,
            items=data.items,
            currency=data.currency or "USD",
            created_at=datetime.now(),
        )

    def _persist_to_database(self, data: OrderData) -> int:
        order_id = self._repo.save(data)
        logger.info("Order persisted, id=%d", order_id)
        return order_id

    def _charge_payment(self, order_id: int, amount: Decimal) -> None:
        self._payment.charge(order_id, amount)

    def _notify_order_created(self, order_id: int) -> None:
        self._notifier.send("order_created", {"order_id": order_id})

    def _build_result(self, order_id: int, data: OrderData) -> OrderResult:
        return OrderResult(id=order_id, status="created", currency=data.currency)
```

**Anti-pattern (do NOT write like this):**

```python
# ✗ Wrong: all logic flattened in the public method — reader must parse every line
def create_order(self, data: OrderData) -> OrderResult:
    if not data.customer_id or not data.items:
        raise ValueError("Missing required fields")
    existing = self._repo.find_by_key(data.idempotency_key)
    if existing:
        raise ValueError("Duplicate order")
    data.currency = data.currency or "USD"
    data.created_at = datetime.now()
    order_id = self._repo.save(data)
    self._payment.charge(order_id, data.amount)
    self._notifier.send("order_created", {"order_id": order_id})
    return OrderResult(id=order_id, status="created", currency=data.currency)
# Same logic, but the reader must read every line to understand the business flow
```

### Recursive Application

```
OrderService.create_order()                  ← Public method, reads like a business flow
  ├── _validate_order_data(data)             ← Private method
  ├── _ensure_no_duplicate(key)              ← Private method
  ├── _enrich_with_defaults(data)            ← Private method
  ├── _persist_to_database(data)             ← Private method
  │     └── repo.save(data)                  ← Click in, same structure
  ├── _charge_payment(order_id, amount)      ← Private method
  │     └── payment.charge(order_id, amount) ← Click in, same structure
  ├── _notify_order_created(order_id)        ← Private method
  └── _build_result(order_id, data)          ← Private method
```

### Private Method Naming Convention

| Verb Prefix | Semantics | Example |
|:---|:---|:---|
| `validate` / `check` | Validate; raise on failure | `_validate_email_format(email)` |
| `ensure` | Assert a condition holds | `_ensure_no_duplicate(key)` |
| `enrich` / `fill` | Populate defaults/derived fields | `_enrich_with_defaults(data)` |
| `persist` / `save` | Write to storage | `_persist_to_database(data)` |
| `notify` / `send` | Send notification/event | `_notify_order_created(order_id)` |
| `build` / `assemble` | Construct return object | `_build_result(order_id, data)` |
| `query` / `find` / `fetch` | Retrieve data | `_find_existing_user(email)` |
| `transform` / `convert` | Convert data format | `_transform_to_internal(raw)` |

### Rules

1. **Public methods only orchestrate** — body contains only private method calls and simple variable passing; no `if`/`try`/`for` procedural logic in the public method body
2. **Private methods are atomic steps** — each does one thing; the method name describes that thing
3. **Recursive layering** — every layer follows the same pattern: public = table of contents, private = chapters
4. **When in doubt, extract** — if a block of code needs a comment to explain "what", extract it into a private method whose name replaces the comment
5. **Prefix with `_`** — all private methods use the Python single-underscore convention

---

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
