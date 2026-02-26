# 성능 가이드라인

## Storage 성능

### Scan 최적화
```kotlin
// GOOD: Bounded scan
val scan = Scan()
    .setPrefix(prefix)
    .setLimit(100)

// BAD: Unbounded scan
val scan = Scan()  // Full table scan!
```

### Batch Operations
```kotlin
// GOOD: Batch writes
storage.putAll(listOfPuts)  // Single RPC

// BAD: Individual writes
puts.forEach { storage.put(it) }  // N RPCs
```

## Messaging 성능

### Producer
- 처리량 향상을 위해 비동기 전송 사용
- 가능하면 메시지를 배치로 묶기
- 압축 고려

### Consumer
- 배치로 처리
- 적절한 commit 전략 사용
- lag 모니터링

## Spring WebFlux

reactive 패턴은 `CLAUDE.md` 참고.

```kotlin
// blocking 호출에는 boundedElastic 사용
Mono.fromCallable { blockingStorageCall() }
    .subscribeOn(Schedulers.boundedElastic())
```

## 일반 규칙

- N+1 쿼리 방지
- 페이지네이션 사용 (cursor 기반)
- 자주 접근하는 데이터는 캐시
- 최적화 전에 프로파일링
- 합리적인 timeout 설정
