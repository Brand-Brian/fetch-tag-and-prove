# Migrations — how schema changes happen from now on

Session 02, 15 September 2026.

From today the database schema is versioned SQL in this repo. **The Supabase
dashboard is read-only for schema.** Read data in it, browse it, run a `select`
in the SQL editor — but every `create`, `alter` and `drop` goes through a file
in `supabase/migrations/`. The reason is short: you cannot roll back a dashboard
click, and you cannot tell what a dashboard click did six weeks later.

## The two projects

| | ref | what it is |
|---|---|---|
| production | `sqzuvtshebrgzivyzyif` | the live site's database, 12 properties / 23 tags / 61 bookings / 3,766 clicks of demo data |
| staging | `crvuzehuiluoxqehtcta` | us-east-2, CTMS Travel, $10/month. Schema-identical to production, **zero rows**. |

Staging is deliberately empty. It is there to prove a migration applies cleanly
to a database shaped like production, not to be a second demo.

## The current migration set

Three files, and both databases agree they are applied:

```
supabase/migrations/
  20260903000000_baseline_schema.sql             tables, constraints, RLS, the six open policies
  20260903000100_baseline_click_views.sql        click_counts, click_weeks, click_months
  20260914174506_create_waitlist_insert_only.sql the waitlist table and its insert-only policy
```

The baseline is dated 3 Sep because that is when those objects really appeared
in production. They were never recorded as migrations, because there was no
migration system until today, so both ledgers have been repaired to say
"already applied" — a metadata write, no DDL. `supabase db push` is now a clean
no-op against both projects, which is the state you want before writing the
next migration.

There is also `supabase/pending/`, which is **not** picked up by the CLI. It
holds a fix that is written but must not be applied on its own — see the file's
own header. Today that is the `security_invoker` fix for the click views, which
belongs in session 04's pass alongside the new policies.

## First-time setup on Brian's machine

This has to happen on your machine, not in a cloud session — the cloud
container's shell cannot reach `supabase.com` at all (organization egress
policy; the connector works, plain `curl` does not).

```bash
brew install supabase/tap/supabase     # or npm i -g supabase
supabase login                          # opens a browser
cd path/to/fetch-tag-and-prove
supabase link --project-ref crvuzehuiluoxqehtcta   # staging
supabase migration list                            # should show 3, all applied both sides
```

`supabase migration list` printing three rows with no "local only" or "remote
only" markers is the check that everything above is true. If it disagrees, stop
and fix the ledger before writing any new migration.

## Writing a migration

```bash
supabase migration new short_snake_case_name     # creates a timestamped file
# edit supabase/migrations/<timestamp>_short_snake_case_name.sql
supabase link --project-ref crvuzehuiluoxqehtcta && supabase db push   # staging first
# verify by OBSERVING the thing the migration was supposed to do
supabase link --project-ref sqzuvtshebrgzivyzyif && supabase db push   # then production
```

Staging first, always. Production second, and only after the staging result was
checked — not after the staging push merely succeeded.

## Verifying, and why the distinction matters

A migration that applies without error is not a migration that worked. Session
01 shipped a `netlify.toml` whose context-scoped header blocks were valid TOML,
parsed fine, and did nothing at all; the `noindex` it was supposed to set was
simply absent. Nothing errored and nothing warned.

So: check the effect, not the exit code. For schema that means comparing the two
databases rather than trusting that the same file produced the same result.
This session's check was a fingerprint — every column with its ordinal position,
type, nullability, generated-ness and default, plus every constraint, index,
policy, view definition, RLS flag and role grant, hashed. Both projects returned
`0a2a002b940e94c1cbe5e1363f683ba6` over 128 lines.

That is worth re-running after any migration that touches both. The query is in
`FETCH_Session_02_Migrations.md` in the project.

**It earned its keep immediately.** The first pass of the baseline wrote the
three `bookings` money columns as bare `numeric`, because that is what the
connector's table listing reports — it drops the precision. Production has
`numeric(10,2)`. Staging would have silently accepted booking values production
rounds. A sorted-line comparison then missed a second problem: fixing the type
by dropping and re-adding the generated columns moved them to the end of the
table, so column *order* diverged. Both are fixed; the fingerprint now includes
ordinal position so neither can recur unnoticed.

## What was deliberately not migrated

The demo data. Staging has the shape and none of the rows. Seeding it is
session 41's job ("demo workspace — the flag, the seeding script, the
one-command reset"), and doing it early would mean two sets of fictional rows
to keep in step.
