---
name: v3-transition
description: V2→V3 엔진 전환 패턴. 현재 V3 API + V2 엔진 구조에서 V3 엔진을 만들기 위한 추상화 설계.
---

# V3 전환 패턴

## 현재 상태

```
V3 API (Controller) → MutationService → MutationEngine (interface)
                                              ↓
                                        V2BackedEngine (V2 Graph 래핑)
                                              ↓
                                        V2BackedTableBinding (HBase)
                                        V2BackedMessageBinding (WAL/CDC)
```

V3 API는 이미 존재하지만, 엔진은 V2를 래핑해서 쓰고 있다.
목표는 `MutationEngine`/`TableBinding` 인터페이스의 V3 네이티브 구현체를 만드는 것.

## 전환 전략

### 1단계: 추상화 추출 (완료 — PR #201)

V2 내부를 직접 참조하던 코드에서 인터페이스를 추출.

```kotlin
// 추상화 (engine 모듈) — V2/V3 무관
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

### 2단계: V2 래핑 구현 (완료 — PR #201)

V2 내부를 `V2Backed*` 클래스로 캡슐화.

```
engine/
├── MutationEngine.kt              # 인터페이스
├── MutationContext.kt              # Context
├── binding/TableBinding.kt         # 인터페이스
├── service/MutationService.kt      # 범용 오케스트레이션
└── v2/engine/v3/
    ├── V2BackedEngine.kt           # Graph 래핑
    ├── V2BackedTableBinding.kt     # HBase 래핑
    └── V2BackedMessageBinding.kt   # WAL/CDC 래핑
```

### 3단계: V3 네이티브 구현 (목표)

같은 인터페이스에 V3 구현체를 붙인다. `MutationService`는 변경 없음.

```
engine/
├── MutationEngine.kt              # 인터페이스 (변경 없음)
├── service/MutationService.kt      # 범용 (변경 없음)
├── v2/engine/v3/V2BackedEngine.kt  # 기존 유지
└── v3/
    ├── V3Engine.kt                 # 새 구현체 (예: SlateDB)
    ├── V3TableBinding.kt
    └── V3MessageBinding.kt
```

## 핵심 설계 원칙

### 인터페이스는 engine 모듈, 구현체는 하위 패키지

```
engine/                    ← 인터페이스 (V2/V3 무관)
engine/v2/engine/v3/       ← V2 구현체 (V2Backed*)
engine/v3/                 ← V3 구현체 (미래)
```

### V2 변환은 V2Backed* 내부에만

```kotlin
// V2BackedMessageBinding 내부 — V2 타입 변환
private fun MutationEvent.toV2TraceEdge(): TraceEdge = ...
private fun EventType.toV2(): EdgeOperation = ...
private fun Audit.toV2(): V2Audit = ...
```

V2 변환 로직이 추상화 계층 위로 새면 안 된다.

### Sealed Type으로 통합

제네릭 대신 sealed type. Edge/MultiEdge를 하나의 타입 계층으로.

```kotlin
sealed interface MutationKey {
    data class SourceTarget(val source: Any, val target: Any) : MutationKey
    data class Id(val id: Any) : MutationKey
}

// 통합 결과 (EdgeMutationStatus + MultiEdgeMutationStatus → MutationResult)
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

Request DTO에서 schema 의존성을 분리. resolve는 engine 레이어에서.

```kotlin
interface UnresolvedEvent {
    fun createEvent(schema: ModelSchema): MutationEvent
}

// MutationService에서 resolve
Flux.fromIterable(unresolvedEvents)
    .map { it.createEvent(tb.schema) }
```

## V3 구현 시 체크리스트

새 `V3Engine`/`V3TableBinding` 구현 시:
- [ ] `MutationEngine` 인터페이스 완전 구현
- [ ] `TableBinding` 인터페이스 완전 구현 (lock, read, write)
- [ ] `MutationService`는 수정하지 않음 — 범용 오케스트레이션
- [ ] V2 타입 import 없음 — V3 구현체에서 V2 패키지 참조 금지
- [ ] 기존 E2E 테스트 통과 (V2BackedEngine과 동일 결과)
