---
description: Reference for writing tests. Data-driven testing, @ObjectSource patterns, E2E/Unit test structure.
---

# Testing Guide

## Design Principle: Data-driven, Easy-to-review Tests

Tests should be centered on **data, not code**.

- E2E tests use **raw JSON strings end-to-end** — request body in, response body out, visible directly in the diff.
- Reviewers should understand what's being tested by **reading only the `@ObjectSource` YAML data**, without tracing test code.
- Minimize builder, helper, and assertion abstractions. Input JSON and expected JSON should be directly visible.
- Test method bodies are thin wrappers around HTTP calls. Business logic is expressed through data.

## Requirements

**Mandatory for all new features:**
1. **Unit Tests** - JUnit 5
2. **Integration Tests** - API endpoints, Storage

## TDD Workflow

1. Write tests first (RED)
2. Run tests — should fail
3. Write minimal implementation (GREEN)
4. Run tests — should pass
5. Refactor (IMPROVE)

## Kotlin Test Patterns

### Test Classification

| Type | Base Class | Verification | Parameterization |
|------|-----------|------------|------------------|
| E2E (API) | `E2ETestBase()` | WebTestClient `.expectStatus()`, `.expectBody().json()` | `@ObjectSourceParameterizedTest` + `@ObjectSource` (YAML) |
| Unit | None | AssertJ `assertThat()`, `assertThatThrownBy()` | `@ObjectSourceParameterizedTest` + `@ObjectSource` (YAML) |

### Test File Structure

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

**Key Rules:**
- **One function, one capability.** Each test function verifies a single operation. Input and output should be clear from `@ObjectSource` data alone.
- Prefer independent tests with `@BeforeAll` for precondition setup.
- When state dependencies are unavoidable (e.g., update requires create in CRUD), use `@TestMethodOrder(OrderAnnotation::class)` + `@Order(n)`. Keep ordered tests minimal — only when genuine sequential dependencies exist.
- Apply `@TestInstance(PER_CLASS)` to all classes/nested classes using `@BeforeAll`
- Use `@Nested` inner classes for logical grouping
- Use backtick method names that describe the operation

### E2E Tests (API)

Extend `E2ETestBase()` and verify with WebTestClient HTTP calls.

**Create (POST + GET verification):**

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

**Update (PUT + verification):**

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

**Cross-version compatibility:**

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

**@ObjectSource Guidelines:**
- Use YAML `|` (literal block) for JSON payloads — no escaping needed
- Use YAML `#` comments to group related test cases
- Function parameter names must exactly match YAML keys
- Supported types: String, Int, Long, Boolean, List, Map (Jackson conversion)

**@ObjectSource Parameters:**

```kotlin
@ObjectSource(
    value: String = "",   // test case data (default parameter)
    cases: String = "",   // alias for value — preferred when shared is present
    shared: String = "",  // shared fields merged into every test case
)
```

- `@ObjectSource("...")` -- existing usage, backward compatible
- `@ObjectSource(cases = "...")` -- alias for `value`, use with `shared` for readability
- `@ObjectSource(shared = "...", cases = "...")` -- `shared` fields merged into all test cases; `cases` fields override `shared` fields

**Shared fields with `shared`:**

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
    setup: String,     // from shared — same for all cases
    name: String,      // from cases — per case
    update: String,    // from cases — per case
)
```

**Imports:**
```kotlin
import com.kakao.actionbase.test.documentations.params.ObjectSource
import com.kakao.actionbase.test.documentations.params.ObjectSourceParameterizedTest
```

### Unit Tests

No base class. Use AssertJ for verification.

**Given/When/Then inline object approach:**

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

**Parameterized with @ObjectSource (enum/mapping tests):**

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

**Parameterized with @ObjectSource (validation tests):**

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

**Exception tests:**

```kotlin
@Test
fun `unknown type should throw`() {
    assertThatThrownBy { converter.convert(unknownInput) }
        .isInstanceOf(IllegalArgumentException::class.java)
        .hasMessageContaining("Unknown type")
}
```

### Parameterization Decision Guide

| Scenario | Use |
|-----------|-----|
| Parameterized test (all cases) | `@ObjectSourceParameterizedTest` + `@ObjectSource` (YAML) |
| Single scenario, no repetition | `@Test` |

**Always use `@ObjectSource`** for parameterized tests — even for simple enum mappings or string validation lists. This maintains a consistent format across the project for easy review. Do not use `@CsvSource` or `@ValueSource`.

### Coverage Strategy

- **Happy path**: Independent verification per capability (create, get, update, deactivate, delete)
- **Validation**: Invalid input, empty strings, special characters, max length
- **Cross-version**: V2 → V3 and V3 → V2 bidirectional compatibility
- **Boundary values**: Edge cases (empty, max length, exceeds max)
- **Security**: Injection attempts (dot notation, path traversal)
- **Error codes**: 400 (bad request), 404 (not found), 409 (conflict)
