# Core 모듈

## 목적

데이터 모델 정의, 인코딩 로직, 유효성 검사 규칙을 담당한다.
외부 의존성 없음 (순수 Kotlin/Java).

## 패키지 구조

```
core/src/main/kotlin/.../
├── model/
│   ├── Mutation.kt       # Mutation 데이터 클래스
│   ├── Query.kt          # Query 데이터 클래스
│   ├── Schema.kt         # Schema 정의
│   └── Interaction.kt    # 저장된 인터랙션
├── encoding/
│   ├── RowKeyBuilder.kt  # Row key 생성 (확정됨)
│   └── ValueEncoder.kt   # 값 직렬화
├── validation/
│   └── MutationValidator.kt
└── result/
    └── Result.kt         # 결과를 위한 sealed class
```

## 주요 클래스

### Mutation
```kotlin
data class Mutation(
    val schema: String,
    val userId: String,
    val targetId: String,
    val action: Action = Action.CREATE,
    val timestamp: Long = System.currentTimeMillis()
)
```

### Query
```kotlin
data class Query(
    val schema: String,
    val userId: String,
    val limit: Int = 100,
    val cursor: String? = null
)
```

### Result 패턴
```kotlin
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String) : Result<Nothing>()
}
```

## 인코딩

Row key 형식은 확정되었다. `/internals/encoding/` 문서를 참고할 것.

인코딩 로직은 신중한 검토 없이 수정하지 말 것.

## 의존성

- 없음 (순수 도메인 모델)
- 사용처: engine, server
