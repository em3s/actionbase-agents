# Server 모듈

## 목적

Spring WebFlux를 사용하는 REST API. HTTP 요청 처리, 유효성 검사, 응답 포맷팅을 담당한다.

## 패키지 구조

```
server/src/main/kotlin/.../
├── Application.kt            # 메인 진입점
├── controller/
│   ├── MutationController.kt # POST /api/v1/mutation
│   ├── QueryController.kt    # GET /api/v1/query
│   └── SchemaController.kt   # Schema 관리
├── service/
│   ├── MutationService.kt    # 비즈니스 로직
│   └── QueryService.kt
├── dto/
│   ├── MutationRequest.kt
│   ├── MutationResponse.kt
│   ├── QueryRequest.kt
│   └── QueryResponse.kt
├── config/
│   ├── WebConfig.kt
│   └── SecurityConfig.kt
└── exception/
    └── GlobalExceptionHandler.kt
```

## API 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | `/api/v1/mutation` | 인터랙션 생성/삭제 |
| GET | `/api/v1/query` | 인터랙션 조회 |
| GET | `/api/v1/schemas` | Schema 목록 조회 |
| GET | `/api/v1/schemas/{name}` | Schema 상세 조회 |

## Controller 패턴

```kotlin
@RestController
@RequestMapping("/api/v1")
class MutationController(
    private val mutationService: MutationService
) {
    @PostMapping("/mutation")
    fun create(@RequestBody request: MutationRequest): Mono<ApiResponse<MutationResult>> {
        return mutationService.process(request.toMutation())
            .map { ApiResponse.success(it) }
            .onErrorResume { ApiResponse.error(it) }
    }
}
```

## Reactive 규칙

- 모든 엔드포인트는 `Mono<T>` 또는 `Flux<T>`를 반환해야 한다
- Controller/Service 레이어에서 절대 블로킹하지 말 것
- Engine의 블로킹 호출에는 `subscribeOn(boundedElastic())`을 사용할 것

## 의존성

- core (모델)
- engine (Storage/Messaging)
- Spring WebFlux
