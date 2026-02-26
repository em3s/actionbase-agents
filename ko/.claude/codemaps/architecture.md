# Actionbase 아키텍처

## 개요

Actionbase는 사용자 인터랙션(좋아요, 조회, 팔로우)을 대규모로 서빙하기 위한 데이터베이스이다.
쓰기 시점에 모든 것을 사전 계산하여 빠르고 예측 가능한 읽기를 제공한다.

## 핵심 개념

**누가(who)** **무엇을(what)** 어떤 **대상(target)**에 했는가

## 모듈 의존성

```
Server (WebFlux) → Engine (Storage/Messaging) → Core (모델, 인코딩, 유효성 검증)
```

## 데이터 흐름

### Mutation (쓰기)
```
Client → Server → Engine → Storage
                       ↘→ Messaging (CDC)
```

### Query (읽기)
```
Client → Server → Engine → Storage → Response
```

## 주요 파일

| 모듈 | 진입점 |
|------|--------|
| core | `core/src/main/.../Mutation.kt`, `Query.kt`, `Schema.kt` |
| engine | `engine/src/main/.../MutationEngine.kt`, `QueryEngine.kt` |
| server | `server/src/main/.../Application.kt` |

## 외부 의존성

| 컴포넌트 | 현재 사용 | 추상화 |
|----------|----------|--------|
| Data Store | HBase | Storage |
| Event Stream | Kafka | Messaging |
| Metadata | MySQL | Metastore |

## 빌드

- **Kotlin/Java**: Gradle 8+ (Kotlin DSL)
