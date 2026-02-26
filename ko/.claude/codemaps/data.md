# 데이터 모델

## 핵심 엔티티

### Interaction

Actionbase의 기본 데이터 단위이다.

| 필드 | 타입 | 설명 |
|------|------|------|
| schema | String | 인터랙션 유형 (likes, follows, views) |
| userId | String | 액션을 수행한 사용자 |
| targetId | String | 액션의 대상 |
| action | Enum | CREATE 또는 DELETE |
| timestamp | Long | 액션 발생 시각 |
| properties | Map | 선택적 메타데이터 |

### Schema

인터랙션 유형의 구조를 정의한다.

| 필드 | 타입 | 설명 |
|------|------|------|
| name | String | 고유 식별자 |
| description | String | 사람이 읽을 수 있는 설명 |
| indexes | List | 인덱스 설정 |
| ttl | Duration | Time-to-live (선택) |

## 스토리지 모델

Row key 인코딩은 확정되었다. [Encoding Documentation](/internals/encoding/)을 참고할 것.

### Row 유형

| 유형 | 코드 | 용도 |
|------|------|------|
| Edge State | -3 | 현재 상태 (Get 쿼리) |
| Edge Index | -4 | 인덱스 항목 (Scan 쿼리) |
| Edge Count | -2 | 카운터 (Count 쿼리) |

### Key 구조

```
[4-byte hash] + [1-byte + source] + [1-byte + table code] + [1-byte + type code] + [additional fields...]
```

- Hash: 리전 분산을 위한 xxhash32
- Type codes: 음수 값 (-2, -3, -4)
- Strings: 1-byte 길이 접두사

## 쿼리 패턴

### Forward Query
사용자별 인터랙션을 조회한다.
```
Schema: likes, User: alice → alice가 좋아요한 모든 게시물
```

### Reverse Query
대상에 인터랙션한 사용자를 조회한다.
```
Schema: likes, Target: post1 → post1을 좋아요한 모든 사용자
```

### Count Query
인터랙션 수를 조회한다.
```
Schema: follows, User: alice → alice가 팔로우하는 사용자 수
```

## CQRS 패턴

- **Mutation 경로**: Server → Engine → Storage + Messaging
- **Query 경로**: Server → Engine → Storage

읽기와 쓰기를 분리하여 각각 최적화한다.
