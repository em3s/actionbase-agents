# Engine 모듈

## 목적

Storage와 Messaging 바인딩을 담당한다. Core 모델을 외부 시스템에 연결한다.

## 패키지 구조

```
engine/src/main/kotlin/.../
├── storage/
│   ├── StorageClient.kt      # 추상 스토리지 인터페이스
│   ├── HBaseStorageClient.kt # HBase 구현체
│   └── StorageConfig.kt
├── messaging/
│   ├── MessagingProducer.kt  # 추상 프로듀서
│   ├── KafkaProducer.kt      # Kafka 구현체
│   └── MessagingConfig.kt
├── mutation/
│   └── MutationEngine.kt     # Mutation 처리
└── query/
    └── QueryEngine.kt        # Query 처리
```

## 주요 클래스

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

## Storage 추상화

| 메서드 | 설명 |
|--------|------|
| `put(key, value)` | 단일 row 쓰기 |
| `putBatch(rows)` | 배치 쓰기 |
| `get(key)` | 단일 row 조회 |
| `scan(prefix, limit)` | Prefix scan |

## Messaging 추상화

| 메서드 | 설명 |
|--------|------|
| `send(topic, key, event)` | 이벤트 전송 |
| `sendBatch(events)` | 배치 전송 |

## Non-Blocking (필수)

모든 Storage/Messaging 호출은 반드시 `Schedulers.boundedElastic()`을 사용해야 한다:

```kotlin
Mono.fromCallable { storageClient.put(key, value) }
    .subscribeOn(Schedulers.boundedElastic())
```

## 의존성

- core (모델)
- HBase client
- Kafka client
- 사용처: server
