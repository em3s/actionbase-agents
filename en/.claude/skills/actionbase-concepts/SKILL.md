---
name: actionbase-concepts
description: Actionbase core concepts — including mutation, query, schema, and datastore architecture.
---

# Actionbase Core Concepts

Understand the fundamental concepts of Actionbase — a database designed to serve large-scale user interactions.

## What Is Actionbase?

Actionbase is a database designed to efficiently store and query user interactions (likes, follows, views, etc.) at scale. It handles millions of requests per minute at Kakao.

## Core Concepts

### 1. Schema

A Schema defines the structure of a user interaction type.

```
Schema: "likes"
- Represents: User likes content
- Row Key: userId + targetId
- Query Pattern: Get all content user X likes
```

**Schema Types:**
- **Likes**: User likes content/posts
- **Follows**: User follows another user
- **Views**: User views content
- **Bookmarks**: User saves content

### 2. Mutation

A Mutation is a write operation that records a user interaction.

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

**Mutation Types:**
- `CREATE`: Add a new interaction
- `DELETE`: Remove an existing interaction

### 3. Query

A Query is a read operation that retrieves user interactions.

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

**Query Patterns:**
- **Forward Query**: Get interactions by user
- **Reverse Query**: Get users who interacted with a target
- **Count Query**: Get interaction count

### 4. Datastore

The Datastore is the storage layer that persists interactions.

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

**Row Key Design:** The finalized row key format is documented in the [Encoding docs](/internals/encoding/).

## Architecture

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

## Data Flow

### Mutation Flow

```
1. Client sends POST /api/v1/mutation
   {
     "schema": "likes",
     "userId": "user123",
     "targetId": "post456"
   }

2. Server validates request
   - Schema exists
   - Required fields present

3. Core processes mutation
   - Generate row key
   - Encode data

4. Engine persists to Storage
   - Put operation
   - Single row write

5. Messaging receives CDC event
   - Event: INTERACTION_CREATED
   - Available for downstream processing

6. Response returned
   {
     "success": true,
     "id": "mut_abc123"
   }
```

### Query Flow

```
1. Client sends GET /api/v1/query?schema=likes&userId=user123

2. Server validates request
   - Schema exists
   - Required fields present

3. Core builds query
   - Generate row key prefix
   - Set scan parameters

4. Engine queries Storage
   - Scan with prefix filter
   - Limit results

5. Response returned
   {
     "data": [
       {"targetId": "post456", "timestamp": 1234567890},
       {"targetId": "post789", "timestamp": 1234567891}
     ],
     "nextCursor": "abc123"
   }
```

## Module Responsibilities

### Core Module (`core/`)
- Data model definitions (Mutation, Query, Schema)
- Encoding/decoding logic
- Validation rules
- Business logic

### Engine Module (`engine/`)
- Storage client bindings
- Messaging producer/consumer
- Storage operations
- Message processing

### Server Module (`server/`)
- REST API endpoints
- Request/response handling
- Authentication/authorization
- Rate limiting

## Best Practices

### Schema Design
```
DO:
- Use short, descriptive schema names
- Consider query patterns when designing
- Plan for scalability (millions of users)

DON'T:
- Use complex nested schemas
- Store large payloads in interactions
- Create too many schema types
```

### Row Key Design

The row key format is finalized. See the [Encoding docs](/internals/encoding/) for details.

Follow existing implementation patterns when modifying storage code.

### Query Optimization
```
DO:
- Always use pagination (cursors)
- Set reasonable limits (100-1000)
- Use specific schema filters

DON'T:
- Full table scans
- Request unlimited results
- Query without userId filter
```

## Common Use Cases

### Social Media "Likes"
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

### Follow System
```kotlin
// Follow a user
mutation(schema = "follows", userId = "alice", targetId = "bob")

// Unfollow
mutation(schema = "follows", userId = "alice", targetId = "bob", action = DELETE)

// Get Alice's following list
query(schema = "follows", userId = "alice")
```

### View History
```kotlin
// Record a view
mutation(schema = "views", userId = "alice", targetId = "article123")

// Get recently viewed articles
query(schema = "views", userId = "alice", limit = 10)
```

## Glossary

| Term | Definition |
|------|-----------|
| **Schema** | Definition of an interaction type |
| **Mutation** | Write operation (create/delete interaction) |
| **Query** | Read operation (retrieve interactions) |
| **Datastore** | Storage layer (currently HBase) |
| **Row Key** | Unique identifier for a storage row |
| **CDC** | Change Data Capture via Messaging |
| **WAL** | Write-Ahead Log for durability |
| **Metastore** | Schema metadata database (currently MySQL) |

**Remember**: Actionbase is designed for high-throughput, low-latency user interaction serving. Always consider scalability when designing schemas and queries.
