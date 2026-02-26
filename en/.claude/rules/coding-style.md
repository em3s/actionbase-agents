# Coding Style

## General Rules

- **File size**: Max 800 lines
- **Function size**: Max 50 lines
- **Nesting depth**: Max 4 levels
- **Immutability**: Prefer immutable data structures
- **Backend language**: Kotlin preferred

## Kotlin Patterns

### Data Class (with defaults)
```kotlin
data class Edge(
    val version: Long,
    val source: Any,
    val target: Any,
    val properties: Map<String, Any?> = emptyMap(),
)
```

### Sealed Class (type hierarchy)
```kotlin
sealed class EdgeRecord {
    sealed class Key {
        data class CommonPrefix(val source: Any, val tableCode: Int, val typeCode: Byte)
    }
}
```

### Enum (abstract methods)
```kotlin
enum class PrimitiveType {
    INT { override fun cast(value: Any): Any = (value as Number).toInt() },
    LONG { override fun cast(value: Any): Any = (value as Number).toLong() };
    abstract fun cast(value: Any): Any
}
```

### Extension Function
```kotlin
object MapperExtensions {
    fun ByteArrayBuffer.encodeKeyPrefix(source: Any): ByteArrayBuffer {
        return this
    }
}
```

### Spring WebFlux
```kotlin
@GetMapping("/users/{id}")
fun getUser(@PathVariable id: String): Mono<User> {
    return userService.findById(id)
}

// Blocking calls must use boundedElastic
Mono.fromCallable { blockingStorageCall() }
    .subscribeOn(Schedulers.boundedElastic())
```

## Java Patterns

### Immutable Class
```java
public class JvmInfo {
    private final String runtimeVersion;
    private final String vmVersion;
    public JvmInfo(String runtimeVersion, String vmVersion) {
        this.runtimeVersion = runtimeVersion;
        this.vmVersion = vmVersion;
    }
}
```

### Enum (abstract methods)
```java
public enum Order {
    ASC { public int cmp(int cmp) { return cmp; } },
    DESC { public int cmp(int cmp) { return -1 * cmp; } };
    public abstract int cmp(int var1);
}
```

## Architecture Patterns

### CQRS
```kotlin
// Mutation path
class MutationService(val engine: MutationEngine)
class MutationEngine(val storage: StorageClient, val messaging: MessagingClient)

// Query path
class QueryService(val engine: QueryEngine)
class QueryEngine(val storage: StorageClient)
```

### Repository Pattern
```kotlin
interface InteractionRepository {
    fun save(interaction: Interaction): Mono<Void>
    fun findByUserId(userId: String): Flux<Interaction>
}
```

## Naming Conventions

- **Kotlin/Java**: `camelCase` for variables, `PascalCase` for classes
- **Files**: `PascalCase.kt` (Kotlin), `PascalCase.java` (Java)

## Anti-patterns

- **God Object**: One class handling everything
- **Magic Number**: Use named constants
- **Deep Nesting**: Use early returns
- **Tight Coupling**: Use dependency injection

## Flow Readability

Business logic should **read top-to-bottom in a single chain**.

### DO
- When consolidating similar code, **push only the differences out as parameters** and keep the common flow in the chain
- Structure so the entire flow is visible within one function
- Prefer clear flow even with slight duplication

```kotlin
// GOOD: Single chain, reads in one pass
request
    .toEvents(schema)
    .writeWal(ctx)
    .groupBy { edge }
    .flatMap { mutateGroup() }
    .collectList()
    .map(toResponse)
```

### DON'T
- Don't extract common logic into infrastructure functions and leave business logic in caller lambdas
- Don't create structures requiring 3+ jumps to follow the flow

```kotlin
// BAD: caller → pipeline → caller's lambda → caller (3 jumps)
executeMutationPipeline(
    events = eventFlux,
    executeGroup = { key, group ->
        sort -> mutate -> writeCDC -> err
    },
).map { toResponse() }
```

## Comment Rules

- Explain WHY, not WHAT
- KDoc for public APIs
- Delete commented-out code (use git history)
