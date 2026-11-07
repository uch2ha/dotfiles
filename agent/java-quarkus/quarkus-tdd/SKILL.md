---
name: quarkus-tdd
description: Quarkus-specific testing: pure JUnit 5 for rule code, @QuarkusTest with REST Assured and Dev Services Postgres for the API. Use with the tdd skill when writing backend tests.
---

# Quarkus testing

Follow the `tdd` skill for the loop; this only adds Quarkus specifics.

## Two kinds of test
1. **Pure unit tests** (JUnit 5 + AssertJ) for core business rules. No `@QuarkusTest`, no mocks of our own code. Fast; most tests live here.
2. **`@QuarkusTest` + REST Assured** for resource → service → DB through the real HTTP API. Postgres comes from Dev Services (throwaway container); Flyway runs the real migrations, so migrations are tested too.

## Rules
- Test behaviour through the interface, not private methods or call counts.
- Assert money with `isEqualByComparingTo(new BigDecimal("12.50"))`, never `double`.
- Fix dates (pass a `Clock`/`LocalDate` in); never depend on `LocalDate.now()` in rule code.
- Tests that touch the DB clean up with `@Transactional` setup or a fresh state per test; no order dependency.
- Use invented data only: no real amounts, names or passwords.
- Run: `./mvnw test` (single class: `./mvnw test -Dtest=ClassName`).
