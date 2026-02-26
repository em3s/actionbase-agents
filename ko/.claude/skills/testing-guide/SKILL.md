---
description: 테스트 작성 시 참조. 데이터 중심 테스트, @ObjectSource 패턴, E2E/Unit 테스트 구조.
---

# 테스트 가이드

## 설계 원칙: 데이터 중심, 리뷰하기 쉬운 테스트

테스트는 **코드가 아닌 데이터** 중심으로 작성한다.

- E2E 테스트는 **raw JSON 문자열을 end-to-end로** 사용 -- request body 입력, response body 출력이 diff에서 바로 보여야 한다.
- 리뷰어는 테스트 코드를 추적하지 않고 **`@ObjectSource` YAML 데이터만 읽고도** 무엇을 테스트하는지 이해할 수 있어야 한다.
- builder, helper, assertion 추상화를 최소화할 것. 입력 JSON과 기대 JSON이 직접 보여야 한다.
- 테스트 메서드 본문은 HTTP 호출을 감싸는 얇은 래퍼. 비즈니스 로직은 데이터로 표현한다.

## 요구사항

**새 기능에는 모두 필수:**
1. **Unit Tests** - JUnit 5
2. **Integration Tests** - API endpoints, Storage

## TDD 워크플로우

1. 테스트를 먼저 작성 (RED)
2. 테스트 실행 - 실패해야 함
3. 최소한의 구현 작성 (GREEN)
4. 테스트 실행 - 통과해야 함
5. 리팩토링 (IMPROVE)

## Kotlin 테스트 패턴

### 테스트 분류

| 유형 | 기본 클래스 | 검증 | 파라미터화 |
|------|-----------|------------|------------------|
| E2E (API) | `E2ETestBase()` | WebTestClient `.expectStatus()`, `.expectBody().json()` | `@ObjectSourceParameterizedTest` + `@ObjectSource` (YAML) |
| Unit | 없음 | AssertJ `assertThat()`, `assertThatThrownBy()` | `@ObjectSourceParameterizedTest` + `@ObjectSource` (YAML) |

### 테스트 파일 구조

```kotlin
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class FeatureTest : E2ETestBase() {

    @Nested
    @TestInstance(TestInstance.Lifecycle.PER_CLASS)
    inner class CreateDatabaseTest {
        @ObjectSourceParameterizedTest @ObjectSource(""" ... """)
        fun `create database`(name: String, create: String, expected: String) { ... }
    }

    @Nested
    @TestInstance(TestInstance.Lifecycle.PER_CLASS)
    inner class CompatibilityTest {
        @BeforeAll
        fun setup() { /* create prerequisite resources */ }

        @ObjectSourceParameterizedTest @ObjectSource(""" ... """)
        fun `V2 create - V3 get`(name: String, create: String, expected: String) { ... }
    }

    @Nested
    inner class ValidationTest {
        @ParameterizedTest
        @ValueSource(strings = ["invalid!", "has space", "a".repeat(65)])
        fun `invalid names should fail`(name: String) { ... }
    }
}
```

**핵심 규칙:**
- **하나의 함수, 하나의 기능.** 각 테스트 함수는 단일 작업을 검증한다. `@ObjectSource` 데이터만으로 입력과 출력을 알 수 있어야 한다.
- 사전 조건 설정에는 `@BeforeAll`을 사용한 독립적 테스트를 선호할 것.
- 상태 의존성이 불가피한 경우(예: CRUD에서 update는 create 필요), `@TestMethodOrder(OrderAnnotation::class)` + `@Order(n)` 사용. 순서가 있는 테스트는 진짜 순차적 의존성이 있는 경우에만 최소한으로 유지할 것.
- `@BeforeAll`을 사용하는 모든 클래스/중첩 클래스에 `@TestInstance(PER_CLASS)` 적용
- 논리적 그룹화를 위해 `@Nested` inner class 사용
- 작업을 설명하는 백틱 메서드 이름 사용

### E2E 테스트 (API)

`E2ETestBase()`를 상속하고 WebTestClient로 HTTP 검증 수행.

**생성 (POST + GET 검증):**

```kotlin
@ObjectSourceParameterizedTest
@ObjectSource(
    """
    - name: db-basic
      create: |
        {"database": "db-basic", "comment": "test database"}
      expected: |
        {"database": "db-basic", "comment": "test database", "active": true}
    - name: db-empty
      create: |
        {"database": "db-empty", "comment": ""}
      expected: |
        {"database": "db-empty", "comment": "", "active": true}
    """,
)
fun `create database`(name: String, create: String, expected: String) {
    client.post().uri("/graph/v3/databases")
        .contentType(MediaType.APPLICATION_JSON)
        .bodyValue(create)
        .exchange()
        .expectStatus().isOk
        .expectBody().json(expected)

    client.get().uri("/graph/v3/databases/$name")
        .exchange()
        .expectStatus().isOk
        .expectBody().json(expected)
}
```

**수정 (PUT + 검증):**

```kotlin
@ObjectSourceParameterizedTest
@ObjectSource(
    """
    - name: db-basic
      update: |
        {"comment": "updated comment"}
      expected: |
        {"database": "db-basic", "comment": "updated comment", "active": true}
    - name: db-empty
      update: |
        {"comment": "updated empty"}
      expected: |
        {"database": "db-empty", "comment": "updated empty", "active": true}
    """,
)
fun `update database`(name: String, update: String, expected: String) {
    client.put().uri("/graph/v3/databases/$name")
        .contentType(MediaType.APPLICATION_JSON)
        .bodyValue(update)
        .exchange()
        .expectStatus().isOk
        .expectBody().json(expected)
}
```

**크로스 버전 호환성:**

```kotlin
@ObjectSourceParameterizedTest
@ObjectSource(
    """
    - name: db-v2v3-basic
      create: |
        {"desc": "test database"}
      expected: |
        {"database": "db-v2v3-basic", "comment": "test database", "active": true}
    """,
)
fun `V2 create - V3 get`(name: String, create: String, expected: String) {
    client.post().uri("/graph/v2/service/$name")
        .contentType(MediaType.APPLICATION_JSON)
        .bodyValue(create)
        .exchange()
        .expectStatus().isOk

    client.get().uri("/graph/v3/databases/$name")
        .exchange()
        .expectStatus().isOk
        .expectBody().json(expected)
}
```

**@ObjectSource 가이드라인:**
- JSON payload에는 YAML `|` (literal block) 사용 -- 이스케이프 불필요
- 관련 테스트 케이스를 그룹화할 때 YAML `#` 주석 사용
- 함수 파라미터 이름은 YAML 키와 정확히 일치해야 함
- 지원 타입: String, Int, Long, Boolean, List, Map (Jackson 변환)

**@ObjectSource 파라미터:**

```kotlin
@ObjectSource(
    value: String = "",   // test case data (default parameter)
    cases: String = "",   // alias for value — shared가 있을 때 선호
    shared: String = "",  // 모든 test case에 병합되는 공유 필드
)
```

- `@ObjectSource("...")` -- 기존 사용법, 하위 호환
- `@ObjectSource(cases = "...")` -- `value`의 alias, `shared`와 함께 사용 시 가독성을 위해 사용
- `@ObjectSource(shared = "...", cases = "...")` -- `shared` 필드가 모든 test case에 병합됨; `cases`의 필드가 `shared` 필드를 오버라이드

**`shared`를 사용한 공유 필드:**

```kotlin
@ObjectSourceParameterizedTest
@ObjectSource(
    shared = """
      setup: |
        {"database": "test-db", "comment": "test"}
    """,
    cases = """
    - name: alias-basic
      update: |
        {"comment": "updated"}
    - name: alias-empty
      update: |
        {"comment": ""}
    """,
)
fun `update alias`(
    setup: String,     // from shared — 모든 케이스에서 공유
    name: String,      // from cases — 케이스별
    update: String,    // from cases — 케이스별
)
```

**Imports:**
```kotlin
import com.kakao.actionbase.test.documentations.params.ObjectSource
import com.kakao.actionbase.test.documentations.params.ObjectSourceParameterizedTest
```

### Unit 테스트

기본 클래스 없음. 검증에는 AssertJ 사용.

**Given/When/Then 인라인 객체 방식:**

```kotlin
@Test
fun `ServiceEntity to DatabaseDescriptor`() {
    // Given
    val entity = ServiceEntity(name = "test-db", desc = "description")
    // When
    val result = converter.toDatabaseDescriptor(entity)
    // Then
    assertThat(result.database).isEqualTo("test-db")
    assertThat(result.comment).isEqualTo("description")
    assertThat(result.active).isTrue()
}
```

**@ObjectSource를 사용한 파라미터화 (enum/매핑 테스트):**

```kotlin
@ObjectSourceParameterizedTest
@ObjectSource(
    """
    - v2: SYNC
      v3: SYNC
    - v2: ASYNC
      v3: ASYNC
    """,
)
fun `V2 to V3 MutationMode`(v2: String, v3: String) {
    val result = converter.toV3MutationMode(MutationMode.valueOf(v2))
    assertThat(result.name).isEqualTo(v3)
}
```

**@ObjectSource를 사용한 파라미터화 (유효성 검증 테스트):**

```kotlin
@ObjectSourceParameterizedTest
@ObjectSource(
    """
    - name: valid-name
    - name: test_123
    - name: a
    """,
)
fun `valid names should pass validation`(name: String) {
    assertThat(V3NameValidator.validate(name)).isEqualTo(name)
}

@ObjectSourceParameterizedTest
@ObjectSource(
    """
    - name: ""
    - name: "has space"
    - name: "dot.name"
    - name: "slash/name"
    """,
)
fun `invalid names should fail`(name: String) {
    assertThatThrownBy { V3NameValidator.validate(name) }
        .isInstanceOf(ResponseStatusException::class.java)
}
```

**예외 테스트:**

```kotlin
@Test
fun `unknown type should throw`() {
    assertThatThrownBy { converter.convert(unknownInput) }
        .isInstanceOf(IllegalArgumentException::class.java)
        .hasMessageContaining("Unknown type")
}
```

### 파라미터화 결정 가이드

| 상황 | 사용 |
|-----------|-----|
| 파라미터화 테스트 (모든 케이스) | `@ObjectSourceParameterizedTest` + `@ObjectSource` (YAML) |
| 단일 시나리오, 반복 없음 | `@Test` |

파라미터화 테스트에는 **항상 `@ObjectSource`를 사용**할 것 -- 단순한 enum 매핑이나 문자열 유효성 검증 목록이라도 마찬가지. 프로젝트 전체에서 일관된 형식으로 리뷰할 수 있도록 유지한다. `@CsvSource`나 `@ValueSource`는 사용하지 말 것.

### 커버리지 전략

- **정상 경로**: 기능별 독립 검증 (create, get, update, deactivate, delete)
- **유효성 검증**: 잘못된 입력, 빈 문자열, 특수문자, 최대 길이
- **크로스 버전**: V2 -> V3 및 V3 -> V2 양방향 호환성
- **경계값**: 엣지 케이스 (빈 값, 최대 길이, 초과 길이)
- **보안**: 인젝션 시도 (dot notation, path traversal)
- **에러 코드**: 400 (bad request), 404 (not found), 409 (conflict)
