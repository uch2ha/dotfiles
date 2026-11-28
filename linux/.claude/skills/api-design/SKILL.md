---
name: api-design
description: REST API design patterns including resource naming, status codes, pagination, filtering, error responses, versioning, and rate limiting for production APIs. Use when designing or reviewing REST endpoints, resource names, status codes, pagination, or versioning.
metadata:
  source:
    repo: "github.com/affaan-m/ECC"
    path: "skills/api-design"
    commit: "4adeee6732a12d1540f49a4d50a38ce8c97f9a53"
    license: "MIT"
    checked: "2026-11-27"
  skill-alchemy:
    accept:
      body-size: 8260
---

# API Design Patterns

Conventions and best practices for designing consistent, developer-friendly REST APIs.

## Resource Design

### URL Structure

```
# Resources are nouns, plural, lowercase, kebab-case
GET    /api/v1/users
GET    /api/v1/users/:id
POST   /api/v1/users
PUT    /api/v1/users/:id
PATCH  /api/v1/users/:id
DELETE /api/v1/users/:id

# Sub-resources for relationships
GET    /api/v1/users/:id/orders
POST   /api/v1/users/:id/orders

# Actions that don't map to CRUD (use verbs sparingly)
POST   /api/v1/orders/:id/cancel
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
```

### Naming Rules

```
# GOOD
/api/v1/team-members          # kebab-case for multi-word resources
/api/v1/orders?status=active  # query params for filtering
/api/v1/users/123/orders      # nested resources for ownership

# BAD
/api/v1/getUsers              # verb in URL
/api/v1/user                  # singular (use plural)
/api/v1/team_members          # snake_case in URLs
/api/v1/users/123/getOrders   # verb in nested resource
```

## HTTP Methods and Status Codes

### Method Semantics

| Method | Idempotent | Safe | Use For |
|--------|-----------|------|---------|
| GET | Yes | Yes | Retrieve resources |
| POST | No | No | Create resources, trigger actions |
| PUT | Yes | No | Full replacement of a resource |
| PATCH | No* | No | Partial update of a resource |
| DELETE | Yes | No | Remove a resource |

*PATCH can be made idempotent with proper implementation

### Status Code Reference

```
# Success
200 OK                    — GET, PUT, PATCH (with response body)
201 Created               — POST (include Location header)
204 No Content            — DELETE, PUT (no response body)

# Client Errors
400 Bad Request           — Malformed request (bad JSON, wrong types)
401 Unauthorized          — Missing or invalid authentication
403 Forbidden             — Authenticated but not authorized
404 Not Found             — Resource doesn't exist
409 Conflict              — Duplicate entry, state conflict
422 Unprocessable Entity  — Validation failure (valid JSON, invalid data)
429 Too Many Requests     — Rate limit exceeded

# Server Errors
500 Internal Server Error — Unexpected failure (never expose details)
502 Bad Gateway           — Upstream service failed
503 Service Unavailable   — Temporary overload, include Retry-After
```

### Common Mistakes

- 200 for everything (`{"success": false}`) → use the status code: 404 with `{ "error": { "code": "not_found" } }`
- 500 for validation errors → 422 with field-level details (400 only for malformed input)
- 200 for created resources → 201 with a `Location` header

## Response Format

### Success Response

```json
{ "data": { "id": "abc-123", "email": "alice@example.com", "name": "Alice", "created_at": "2025-01-15T10:30:00Z" } }
```

### Collection Response (with Pagination)

```json
{
  "data": [{ "id": "abc-123", "name": "Alice" }, { "id": "def-456", "name": "Bob" }],
  "meta": { "total": 142, "page": 1, "per_page": 20, "total_pages": 8 },
  "links": { "self": "/api/v1/users?page=1&per_page=20", "next": "/api/v1/users?page=2&per_page=20", "last": "/api/v1/users?page=8&per_page=20" }
}
```

### Error Response

```json
{
  "error": {
    "code": "validation_error",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "message": "Must be a valid email address", "code": "invalid_format" },
      { "field": "age", "message": "Must be between 0 and 150", "code": "out_of_range" }
    ]
  }
}
```

### Envelope or flat

Envelope `{data, meta, links}` / `{error}` for public APIs; flat resource bodies are fine for internal APIs, distinguished by status code. Typed shapes: `references/implementation-examples.md`.

## Pagination

### Offset-Based (Simple)

```
GET /api/v1/users?page=2&per_page=20   # ORDER BY created_at DESC LIMIT 20 OFFSET 20
```

**Pros:** Easy to implement, supports "jump to page N"
**Cons:** Slow on large offsets (OFFSET 100000), inconsistent with concurrent inserts

### Cursor-Based (Scalable)

```
GET /api/v1/users?cursor=eyJpZCI6MTIzfQ&limit=20   # WHERE id > :cursor_id ORDER BY id LIMIT 21 (limit+1 → has_next)
```

```json
{
  "data": [...],
  "meta": {
    "has_next": true,
    "next_cursor": "eyJpZCI6MTQzfQ"
  }
}
```

**Pros:** Consistent performance regardless of position, stable with concurrent inserts
**Cons:** Cannot jump to arbitrary page, cursor is opaque

### When to Use Which

| Use Case | Pagination Type |
|----------|----------------|
| Admin dashboards, small datasets (<10K) | Offset |
| Infinite scroll, feeds, large datasets | Cursor |
| Public APIs | Cursor (default) with offset (optional) |
| Search results | Offset (users expect page numbers) |

## Filtering, Sorting, and Search

### Filtering

```
# Simple equality
GET /api/v1/orders?status=active&customer_id=abc-123

# Comparison operators (use bracket notation)
GET /api/v1/products?price[gte]=10&price[lte]=100
GET /api/v1/orders?created_at[after]=2025-01-01

# Multiple values (comma-separated)
GET /api/v1/products?category=electronics,clothing

# Nested fields (dot notation)
GET /api/v1/orders?customer.country=US
```

### Sorting

```
# Single field (prefix - for descending)
GET /api/v1/products?sort=-created_at

# Multiple fields (comma-separated)
GET /api/v1/products?sort=-featured,price,-created_at
```

Full-text search (`?q=`) and sparse fieldsets (`?fields=`): `references/implementation-examples.md`.

## Authentication and Authorization

### Token-Based Auth

```
# Bearer token in Authorization header
GET /api/v1/users
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

# API key (for server-to-server)
GET /api/v1/data
X-API-Key: sk_live_...
```

### Authorization Patterns

- Resource level: load the resource, return 404 if missing, 403 if the user doesn't own it or isn't permitted.
- Role level: check roles in middleware/filters before the handler runs.

## Rate Limiting

### Headers

```
HTTP/1.1 200 OK
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000

# When exceeded
HTTP/1.1 429 Too Many Requests
Retry-After: 60
{
  "error": {
    "code": "rate_limit_exceeded",
    "message": "Rate limit exceeded. Try again in 60 seconds."
  }
}
```

## Versioning

### URL Path Versioning (Recommended)

```
/api/v1/users
/api/v2/users
```

**Pros:** Explicit, easy to route, cacheable
**Cons:** URL changes between versions

### Header Versioning

```
GET /api/users
Accept: application/vnd.myapp.v2+json
```

**Pros:** Clean URLs
**Cons:** Harder to test, easy to forget

### Versioning Strategy

```
1. Start with /api/v1/ — don't version until you need to
2. Maintain at most 2 active versions (current + previous)
3. Deprecation timeline:
   - Announce deprecation (6 months notice for public APIs)
   - Add Sunset header: Sunset: <HTTP date of shutdown>
   - Return 410 Gone after sunset date
4. Non-breaking changes don't need a new version:
   - Adding new fields to responses
   - Adding new optional query parameters
   - Adding new endpoints
5. Breaking changes require a new version:
   - Removing or renaming fields
   - Changing field types
   - Changing URL structure
   - Changing authentication method
```

## Implementation Patterns

Worked handlers (TypeScript/Next.js + Zod, Python/Django REST Framework, Go net/http, Express authorization): [references/implementation-examples.md](references/implementation-examples.md).

## API Design Checklist

Before shipping a new endpoint:

- [ ] Resource URL follows naming conventions (plural, kebab-case, no verbs)
- [ ] Correct HTTP method used (GET for reads, POST for creates, etc.)
- [ ] Appropriate status codes returned (not 200 for everything)
- [ ] Input validated with schema (Zod, Pydantic, Bean Validation)
- [ ] Error responses follow standard format with codes and messages
- [ ] Pagination implemented for list endpoints (cursor or offset)
- [ ] Authentication required (or explicitly marked as public)
- [ ] Authorization checked (user can only access their own resources)
- [ ] Rate limiting configured
- [ ] Response does not leak internal details (stack traces, SQL errors)
- [ ] Consistent naming with existing endpoints (camelCase vs snake_case)
- [ ] Documented (OpenAPI/Swagger spec updated)
