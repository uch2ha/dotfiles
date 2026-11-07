---
name: quarkus-patterns
description: Quarkus 3.x backend conventions: layering, Panache, REST resources, DTOs, validation, exception mapping, config. Use when building or reviewing backend code.
---

# Quarkus patterns

## Layers
- `resource` (JAX-RS, thin) → `service` (`@ApplicationScoped`, `@Transactional` here) → `repository` (Panache repository) → entity.
- Core business rules are plain Java classes with no CDI, no Panache, no I/O. Services call them; unit tests need no Quarkus.

## Rules
- Prefer Panache **repository** pattern over active record, so domain logic stays framework-free.
- Never return entities from resources. Use records as DTOs; map in the service.
- Money is `BigDecimal` (never floating point) with an explicit `RoundingMode` in one place. Dates: `java.time` types; ISO strings on the API.
- Validate input with Bean Validation (`@Valid`, `@NotNull`, `@Positive`) on DTO records.
- One `ExceptionMapper` per error family returning a JSON body `{code, message}`; never leak stack traces.
- Constructor injection; no field `@Inject` in new code.
- Config via `@ConfigMapping` interfaces and env vars (`application.properties` uses `${VAR:default}`); no secrets in the repo.
- Schema comes only from Flyway migrations: `quarkus.hibernate-orm.database.generation=none`.
- Expose `/q/health` (smallrye-health) for Docker Compose healthchecks.

## Docs
Use context7 for exact Quarkus/Panache API syntax rather than memory.
