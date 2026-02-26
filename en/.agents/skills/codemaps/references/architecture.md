# Actionbase Architecture

## Overview

Actionbase is a database for serving user interactions (likes, views, follows) at scale.
It pre-computes everything at write time to provide fast, predictable reads.

## Core Concept

**Who** did **what** to which **target**

## Module Dependencies

```
Server (WebFlux) → Engine (Storage/Messaging) → Core (model, encoding, validation)
```

## Data Flow

### Mutation (write)
```
Client → Server → Engine → Storage
                       ↘→ Messaging (CDC)
```

### Query (read)
```
Client → Server → Engine → Storage → Response
```

## Key Files

| Module | Entry point |
|--------|-------------|
| core | `core/src/main/.../Mutation.kt`, `Query.kt`, `Schema.kt` |
| engine | `engine/src/main/.../MutationEngine.kt`, `QueryEngine.kt` |
| server | `server/src/main/.../Application.kt` |

## External Dependencies

| Component | Implementation | Abstraction |
|-----------|---------------|-------------|
| Data Store | HBase | Storage |
| Event Stream | Kafka | Messaging |
| Metadata | MySQL | Metastore |

## Build

- **Kotlin/Java**: Gradle 8+ (Kotlin DSL)
