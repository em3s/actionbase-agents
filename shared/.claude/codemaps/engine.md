# Engine Module

## Purpose

Handles Storage and Messaging bindings. Connects Core models to external systems.

## Package Structure

```
engine/src/main/kotlin/.../
├── storage/
│   ├── StorageClient.kt      # Abstract storage interface
│   ├── HBaseStorageClient.kt  # HBase implementation
│   └── StorageConfig.kt
├── messaging/
│   ├── MessagingProducer.kt   # Abstract producer
│   ├── KafkaProducer.kt       # Kafka implementation
│   └── MessagingConfig.kt
├── mutation/
│   └── MutationEngine.kt      # Mutation processing
└── query/
    └── QueryEngine.kt         # Query processing
```

## Key Classes

### MutationEngine
```kotlin
class MutationEngine(
    private val storageClient: StorageClient,
    private val messagingProducer: MessagingProducer
) {
    fun process(mutation: Mutation): Mono<MutationResult>
}
```

### QueryEngine
```kotlin
class QueryEngine(
    private val storageClient: StorageClient
) {
    fun query(query: Query): Flux<Interaction>
}
```

## Storage Abstraction

| Method | Description |
|--------|-------------|
| `put(key, value)` | Single row write |
| `putBatch(rows)` | Batch write |
| `get(key)` | Single row read |
| `scan(prefix, limit)` | Prefix scan |

## Messaging Abstraction

| Method | Description |
|--------|-------------|
| `send(topic, key, event)` | Send event |
| `sendBatch(events)` | Batch send |

## Non-Blocking (required)

All Storage/Messaging calls must use `Schedulers.boundedElastic()`:

```kotlin
Mono.fromCallable { storageClient.put(key, value) }
    .subscribeOn(Schedulers.boundedElastic())
```

## Dependencies

- core (models)
- HBase client
- Kafka client
- Used by: server
