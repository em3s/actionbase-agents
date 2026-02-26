# Data Model

## Core Entities

### Interaction

The fundamental data unit of Actionbase.

| Field | Type | Description |
|-------|------|-------------|
| schema | String | Interaction type (likes, follows, views) |
| userId | String | User who performed the action |
| targetId | String | Target of the action |
| action | Enum | CREATE or DELETE |
| timestamp | Long | Time of the action |
| properties | Map | Optional metadata |

### Schema

Defines the structure of an interaction type.

| Field | Type | Description |
|-------|------|-------------|
| name | String | Unique identifier |
| description | String | Human-readable description |
| indexes | List | Index configuration |
| ttl | Duration | Time-to-live (optional) |

## Storage Model

Row key encoding is finalized. See [Encoding Documentation](/internals/encoding/).

### Row Types

| Type | Code | Purpose |
|------|------|---------|
| Edge State | -3 | Current state (Get queries) |
| Edge Index | -4 | Index entries (Scan queries) |
| Edge Count | -2 | Counters (Count queries) |

### Key Structure

```
[4-byte hash] + [1-byte + source] + [1-byte + table code] + [1-byte + type code] + [additional fields...]
```

- Hash: xxhash32 for region distribution
- Type codes: negative values (-2, -3, -4)
- Strings: 1-byte length prefix

## Query Patterns

### Forward Query
Query interactions by user.
```
Schema: likes, User: alice → all posts alice liked
```

### Reverse Query
Query users who interacted with a target.
```
Schema: likes, Target: post1 → all users who liked post1
```

### Count Query
Query interaction counts.
```
Schema: follows, User: alice → number of users alice follows
```

## CQRS Pattern

- **Mutation path**: Server → Engine → Storage + Messaging
- **Query path**: Server → Engine → Storage

Reads and writes are separated for independent optimization.
