---
name: v3-transition
description: V2→V3 engine transition patterns. Abstraction design for building a V3 engine from the current V3 API + V2 engine structure.
---

# V3 Transition Patterns

## Current State

```
V3 API (Controller) → MutationService → MutationEngine (interface)
                                              ↓
                                        V2BackedEngine (wraps V2 Graph)
                                              ↓
                                        V2BackedTableBinding (HBase)
                                        V2BackedMessageBinding (WAL/CDC)
```

The V3 API already exists, but the engine wraps V2 under the hood.
The goal is to create native V3 implementations of the `MutationEngine`/`TableBinding` interfaces.

## Transition Strategy

### Phase 1: Extract Abstractions (Complete — PR #201)

Extracted interfaces from code that directly referenced V2 internals.

```kotlin
// Abstractions (engine module) — V2/V3 agnostic
interface MutationEngine {
    fun getTableBinding(database: String, alias: String): TableBinding
    fun writeWal(ctx: MutationContext, event: MutationEvent): Mono<Void>
    fun writeCdc(ctx: MutationContext, events: List<MutationEvent>, ...)
    val mutationRequestTimeout: Long
}

interface TableBinding {
    val table: String
    val schema: ModelSchema
    val mutationMode: MutationMode
    fun <T> withLock(key: MutationKey, action: () -> Mono<T>): Mono<T>
    fun read(key: MutationKey): Mono<State>
    fun write(key: MutationKey, before: State, after: State): Mono<MutationRecordsSummary>
    fun handleMutationError(error: Throwable)
}
```

### Phase 2: V2 Wrapped Implementation (Complete — PR #201)

Encapsulated V2 internals in `V2Backed*` classes.

```
engine/
├── MutationEngine.kt              # Interface
├── MutationContext.kt              # Context
├── binding/TableBinding.kt         # Interface
├── service/MutationService.kt      # Generic orchestration
└── v2/engine/v3/
    ├── V2BackedEngine.kt           # Wraps Graph
    ├── V2BackedTableBinding.kt     # Wraps HBase
    └── V2BackedMessageBinding.kt   # Wraps WAL/CDC
```

### Phase 3: V3 Native Implementation (Goal)

Attach V3 implementations to the same interfaces. `MutationService` remains unchanged.

```
engine/
├── MutationEngine.kt              # Interface (unchanged)
├── service/MutationService.kt      # Generic (unchanged)
├── v2/engine/v3/V2BackedEngine.kt  # Kept as-is
└── v3/
    ├── V3Engine.kt                 # New implementation (e.g., SlateDB)
    ├── V3TableBinding.kt
    └── V3MessageBinding.kt
```

## Key Design Principles

### Interfaces in engine module, implementations in sub-packages

```
engine/                    ← Interfaces (V2/V3 agnostic)
engine/v2/engine/v3/       ← V2 implementations (V2Backed*)
engine/v3/                 ← V3 implementations (future)
```

### V2 conversions only inside V2Backed*

```kotlin
// Inside V2BackedMessageBinding — V2 type conversions
private fun MutationEvent.toV2TraceEdge(): TraceEdge = ...
private fun EventType.toV2(): EdgeOperation = ...
private fun Audit.toV2(): V2Audit = ...
```

V2 conversion logic must not leak above the abstraction layer.

### Unify with Sealed Types

Use sealed types instead of generics. Unify Edge/MultiEdge into a single type hierarchy.

```kotlin
sealed interface MutationKey {
    data class SourceTarget(val source: Any, val target: Any) : MutationKey
    data class Id(val id: Any) : MutationKey
}

// Unified result (EdgeMutationStatus + MultiEdgeMutationStatus → MutationResult)
data class MutationResult(
    val key: MutationKey,
    val count: Int,
    val status: String,
    val before: State = State.initial,
    val after: State = State.initial,
    val acc: Long = 0,
)
```

### Request-scoped Context

```kotlin
data class MutationContext(
    val database: String,
    val alias: String,
    val table: String,
    val mutationMode: MutationModeContext,
    val audit: Audit,
    val requestId: String,
)
```

### UnresolvedEvent → MutationEvent

Separate schema dependency from request DTOs. Resolution happens at the engine layer.

```kotlin
interface UnresolvedEvent {
    fun createEvent(schema: ModelSchema): MutationEvent
}

// Resolved in MutationService
Flux.fromIterable(unresolvedEvents)
    .map { it.createEvent(tb.schema) }
```

## V3 Implementation Checklist

When implementing new `V3Engine`/`V3TableBinding`:
- [ ] Fully implement the `MutationEngine` interface
- [ ] Fully implement the `TableBinding` interface (lock, read, write)
- [ ] Do not modify `MutationService` — it's generic orchestration
- [ ] No V2 type imports — V3 implementations must not reference V2 packages
- [ ] Existing E2E tests must pass (same results as V2BackedEngine)
