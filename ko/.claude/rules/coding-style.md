# 코딩 스타일

## 일반 규칙

- **파일 크기**: 최대 800줄
- **함수 크기**: 최대 50줄
- **중첩 깊이**: 최대 4단계
- **불변성**: 불변 자료구조 우선
- **백엔드 언어**: Kotlin 우선

## Kotlin 패턴

### Data Class (기본값 포함)
```kotlin
data class Edge(
    val version: Long,
    val source: Any,
    val target: Any,
    val properties: Map<String, Any?> = emptyMap(),
)
```

### Sealed Class (타입 계층)
```kotlin
sealed class EdgeRecord {
    sealed class Key {
        data class CommonPrefix(val source: Any, val tableCode: Int, val typeCode: Byte)
    }
}
```

### Enum (추상 메서드)
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

// 블로킹 호출은 반드시 boundedElastic
Mono.fromCallable { blockingStorageCall() }
    .subscribeOn(Schedulers.boundedElastic())
```

## Java 패턴

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

### Enum (추상 메서드)
```java
public enum Order {
    ASC { public int cmp(int cmp) { return cmp; } },
    DESC { public int cmp(int cmp) { return -1 * cmp; } };
    public abstract int cmp(int var1);
}
```

## 아키텍처 패턴

### CQRS
```kotlin
// Mutation 경로
class MutationService(val engine: MutationEngine)
class MutationEngine(val storage: StorageClient, val messaging: MessagingClient)

// Query 경로
class QueryService(val engine: QueryEngine)
class QueryEngine(val storage: StorageClient)
```

### Repository 패턴
```kotlin
interface InteractionRepository {
    fun save(interaction: Interaction): Mono<Void>
    fun findByUserId(userId: String): Flux<Interaction>
}
```

## 네이밍 컨벤션

- **Kotlin/Java**: `camelCase` 변수, `PascalCase` 클래스
- **파일**: `PascalCase.kt` (Kotlin), `PascalCase.java` (Java)

## 안티패턴

- **God Object**: 하나의 클래스가 모든 것을 처리
- **Magic Number**: 이름 있는 상수 사용
- **Deep Nesting**: early return 사용
- **Tight Coupling**: 의존성 주입 사용

## 흐름 가독성

비즈니스 로직은 **한 체인에서 위에서 아래로 읽혀야** 한다.

### DO
- 유사한 코드를 통합할 때, **차이점만 파라미터로** 밀어내고 공통 흐름은 체인 안에 유지
- 한 함수 안에서 전체 흐름이 보이도록 구성
- 중복이 약간 있더라도 흐름이 명확한 쪽을 선택

```kotlin
// GOOD: 한 체인, 한 번에 읽힘
request
    .toEvents(schema)
    .writeWal(ctx)
    .groupBy { edge }
    .flatMap { mutateGroup() }
    .collectList()
    .map(toResponse)
```

### DON'T
- 공통 로직을 인프라 함수로 추출하고 비즈니스 로직을 caller 람다로 남기지 말 것
- 흐름을 읽기 위해 3곳 이상을 점프해야 하는 구조를 만들지 말 것

```kotlin
// BAD: caller → pipeline → caller의 lambda → caller (3번 점프)
executeMutationPipeline(
    events = eventFlux,
    executeGroup = { key, group ->
        sort -> mutate -> writeCDC -> err
    },
).map { toResponse() }
```

## 주석 규칙

- WHY를 설명, WHAT이 아님
- public API는 KDoc
- 주석 처리된 코드 삭제 (git history 활용)
