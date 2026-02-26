---
name: actionbase-concepts
description: Actionbase 핵심 개념 - mutation, query, schema, datastore 아키텍처 포함.
---

# Actionbase 핵심 개념

Actionbase의 기본 개념을 이해한다 - 대규모 사용자 인터랙션을 서빙하기 위한 데이터베이스.

## Actionbase란?

Actionbase는 사용자 인터랙션(좋아요, 팔로우, 조회 등)을 대규모로 효율적으로 저장하고 조회하기 위해 설계된 데이터베이스이다. 카카오에서 분당 수백만 건의 요청을 처리한다.

## 핵심 개념

### 1. Schema

Schema는 사용자 인터랙션 유형의 구조를 정의한다.

```
Schema: "likes"
- Represents: User likes content
- Row Key: userId + targetId
- Query Pattern: Get all content user X likes
```

**Schema 유형:**
- **Likes**: 사용자가 콘텐츠/게시물에 좋아요
- **Follows**: 사용자가 다른 사용자를 팔로우
- **Views**: 사용자가 콘텐츠를 조회
- **Bookmarks**: 사용자가 콘텐츠를 저장

### 2. Mutation

Mutation은 사용자 인터랙션을 기록하는 쓰기 연산이다.

```kotlin
data class Mutation(
    val schema: String,      // Schema name (e.g., "likes")
    val userId: String,      // User performing action
    val targetId: String,    // Target of action
    val action: Action,      // CREATE, DELETE
    val timestamp: Long      // When action occurred
)

// Example: User "user123" likes post "post456"
Mutation(
    schema = "likes",
    userId = "user123",
    targetId = "post456",
    action = Action.CREATE,
    timestamp = System.currentTimeMillis()
)
```

**Mutation 유형:**
- `CREATE`: 새 인터랙션 추가
- `DELETE`: 기존 인터랙션 삭제

### 3. Query

Query는 사용자 인터랙션을 조회하는 읽기 연산이다.

```kotlin
data class Query(
    val schema: String,      // Schema to query
    val userId: String,      // User to query for
    val limit: Int = 100,    // Max results
    val cursor: String? = null // Pagination cursor
)

// Example: Get all posts user "user123" likes
Query(
    schema = "likes",
    userId = "user123",
    limit = 20
)
```

**Query 패턴:**
- **Forward Query**: 사용자별 인터랙션 조회
- **Reverse Query**: 대상과 인터랙션한 사용자 조회
- **Count Query**: 인터랙션 수 조회

### 4. Datastore

Datastore는 인터랙션을 영속화하는 스토리지 레이어이다.

```
+-------------------+
|     Storage       |
+-------------------+
| Row Key           | Data                    |
|-------------------|-------------------------|
| likes#user123#001 | target=post456, ts=...  |
| likes#user123#002 | target=post789, ts=...  |
| likes#user456#001 | target=post123, ts=...  |
+-------------------+-------------------------+
```

**Row Key 설계:** 확정된 Row Key 형식은 [Encoding 문서](/internals/encoding/)를 참조.

## 아키텍처

```
                     ┌─────────────────────────────────────────┐
                     │              Actionbase                  │
                     └─────────────────────────────────────────┘
                                       │
        ┌──────────────────────────────┼──────────────────────────────┐
        │                              │                              │
        ▼                              ▼                              ▼
┌───────────────┐            ┌───────────────┐            ┌───────────────┐
│    Server     │            │    Engine     │            │     Core      │
│ (Spring WebFlux)│──────────▶│  (Storage/    │◀──────────│   (Model)     │
│  REST API     │            │   Messaging)  │            │   Logic       │
└───────────────┘            └───────────────┘            └───────────────┘
        │                              │
        │                    ┌─────────┴─────────┐
        │                    │                   │
        │                    ▼                   ▼
        │            ┌───────────────┐   ┌───────────────┐
        │            │   Storage     │   │   Messaging   │
        │            │  (Data Store) │   │  (WAL/CDC)    │
        │            └───────────────┘   └───────────────┘
        │
        ▼
┌───────────────┐
│   Metastore   │
│   (Schemas)   │
│               │
└───────────────┘
```

## 데이터 흐름

### Mutation 흐름

```
1. 클라이언트가 POST /api/v1/mutation 전송
   {
     "schema": "likes",
     "userId": "user123",
     "targetId": "post456"
   }

2. Server가 요청 검증
   - Schema 존재 여부
   - 필수 필드 존재 여부

3. Core가 mutation 처리
   - Row key 생성
   - 데이터 인코딩

4. Engine이 Storage에 영속화
   - Put 연산
   - 단일 row 쓰기

5. Messaging이 CDC 이벤트 수신
   - 이벤트: INTERACTION_CREATED
   - 다운스트림 처리 가능

6. 응답 반환
   {
     "success": true,
     "id": "mut_abc123"
   }
```

### Query 흐름

```
1. 클라이언트가 GET /api/v1/query?schema=likes&userId=user123 전송

2. Server가 요청 검증
   - Schema 존재 여부
   - 필수 필드 존재 여부

3. Core가 query 생성
   - Row key prefix 생성
   - Scan 파라미터 설정

4. Engine이 Storage 조회
   - Prefix 필터로 scan
   - 결과 제한

5. 응답 반환
   {
     "data": [
       {"targetId": "post456", "timestamp": 1234567890},
       {"targetId": "post789", "timestamp": 1234567891}
     ],
     "nextCursor": "abc123"
   }
```

## 모듈별 책임

### Core 모듈 (`core/`)
- 데이터 모델 정의 (Mutation, Query, Schema)
- 인코딩/디코딩 로직
- 유효성 검증 규칙
- 비즈니스 로직

### Engine 모듈 (`engine/`)
- Storage 클라이언트 바인딩
- Messaging producer/consumer
- 스토리지 연산
- 메시지 처리

### Server 모듈 (`server/`)
- REST API 엔드포인트
- 요청/응답 처리
- 인증/인가
- Rate limiting

## 모범 사례

### Schema 설계
```
DO:
- 짧고 설명적인 schema 이름 사용
- 설계 시 query 패턴 고려
- 확장성 고려 (수백만 사용자)

DON'T:
- 복잡한 중첩 schema 사용
- 인터랙션에 대용량 페이로드 저장
- 너무 많은 schema 유형 생성
```

### Row Key 설계

Row key 형식은 확정되었다. 자세한 내용은 [Encoding 문서](/internals/encoding/)를 참조.

스토리지 코드 수정 시 기존 구현 패턴을 따른다.

### Query 최적화
```
DO:
- 항상 페이지네이션 (cursor) 사용
- 합리적인 limit 설정 (100-1000)
- 특정 schema 필터 사용

DON'T:
- 전체 테이블 scan
- 무제한 결과 요청
- userId 필터 없이 query
```

## 일반적인 사용 사례

### 소셜 미디어 "좋아요" 기능
```kotlin
// Like a post
mutation(schema = "likes", userId = "alice", targetId = "post123")

// Unlike a post
mutation(schema = "likes", userId = "alice", targetId = "post123", action = DELETE)

// Get all posts Alice likes
query(schema = "likes", userId = "alice", limit = 20)

// Check if Alice likes post123
query(schema = "likes", userId = "alice", targetId = "post123")
```

### 팔로우 시스템
```kotlin
// Follow a user
mutation(schema = "follows", userId = "alice", targetId = "bob")

// Unfollow
mutation(schema = "follows", userId = "alice", targetId = "bob", action = DELETE)

// Get Alice's following list
query(schema = "follows", userId = "alice")
```

### 조회 이력
```kotlin
// Record a view
mutation(schema = "views", userId = "alice", targetId = "article123")

// Get recently viewed articles
query(schema = "views", userId = "alice", limit = 10)
```

## 용어집

| 용어 | 정의 |
|------|------|
| **Schema** | 인터랙션 유형의 정의 |
| **Mutation** | 쓰기 연산 (인터랙션 생성/삭제) |
| **Query** | 읽기 연산 (인터랙션 조회) |
| **Datastore** | 스토리지 레이어 (현재 HBase) |
| **Row Key** | 스토리지 row의 고유 식별자 |
| **CDC** | Messaging을 통한 Change Data Capture |
| **WAL** | 내구성을 위한 Write-Ahead Log |
| **Metastore** | Schema 메타데이터 데이터베이스 (현재 MySQL) |

**기억할 점**: Actionbase는 고처리량, 저지연 사용자 인터랙션 서빙을 위해 설계되었다. Schema와 query 설계 시 항상 확장성을 고려한다.
