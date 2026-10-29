---
name: check-data
description: Data-integrity checklist for reviewing schema changes, migrations, seeds, backfills and data-access changes. Use when verifying or gating work that touches the database, persisted data or the data-access layer.
---

# Data check

Protect existing rows, not just fresh ones. Report findings and plans; never run destructive SQL or apply migrations to live data.

## Checklist

- **Migrations are backward compatible**: expand, then migrate, then contract. No destructive defaults, and no `NOT NULL` without a backfill. There's a rollback path.
- **Safe on existing data**: what happens to the current rows? Check on a copy or a realistic seed, not an empty database.
- **Seeds and backfills are idempotent**: safe to run twice.
- **Constraints at the database**: foreign keys, unique, check and enum constraints, not just checks in the app.
- **Referential integrity**: what cascades, what blocks, what silently breaks. Look for orphans and duplicates.
- **Transactions**: multi-row writes are atomic. No partial state after a failure.
- **Destructive changes** need a verified backup and rollback plan before they're approved.

## Data-access swaps (ORM, framework or backend migration)

- The same queries return the **same rows in the same order**. Check default ordering, pagination boundaries and soft-deleted rows.
- Serialization is unchanged: dates and timezones, decimals, `null` vs missing, enum casing.
- Writes produce the same rows, including defaults, timestamps and generated ids.
- Connection handling: pooling, shutdown and transaction scope carried over.

## Report

For each finding give the severity, the table, column or migration file, the data-loss risk and the concrete fix. Separate what must happen before the change from what can happen after. State what you reviewed (migrations, seeds, live data) and what you verified versus assumed.
