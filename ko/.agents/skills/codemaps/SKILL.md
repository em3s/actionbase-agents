---
name: codemaps
description: Architecture documentation for Actionbase modules. Use when you need to understand the system architecture, module structure, data flow, or component responsibilities.
---

# Actionbase Codemaps

Per-module architecture documentation for the Actionbase project. These documents describe the internal structure, key classes, data flows, and design decisions for each module.

## Available Codemaps

| Module | Description |
|--------|-------------|
| `architecture` | System-wide architecture overview, module dependencies, data flow |
| `core` | Core module — data models, encoding, validation, business logic |
| `engine` | Engine module — storage bindings, messaging bindings |
| `server` | Server module — Spring WebFlux REST API, request/response handling |
| `data` | Data layer — storage schema, row key design, query patterns |

## Usage

Reference the `references/` directory for detailed per-module documentation:
- `references/architecture.md`
- `references/core.md`
- `references/engine.md`
- `references/server.md`
- `references/data.md`
