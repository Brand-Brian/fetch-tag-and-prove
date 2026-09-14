# Environments and the variable contract

Session 01, Phase 0. Written against what the repo and the live project
actually do, not against what the roadmap assumed.

## Three environments

| Context | Netlify | Supabase project | `FETCH_ENV` | Indexed |
|---|---|---|---|---|
| Production | `main` → fetch-and-prove.netlify.app | `Fetch and Prove` — `sqzuvtshebrgzivyzyif` | `production` | yes |
| Staging | `staging` branch deploy | `fetch-staging` — `crvuzehuiluoxqehtcta` | `staging` | no |
| Preview | pull request deploy | `fetch-staging` — `crvuzehuiluoxqehtcta` | `preview` | no |

Both projects are in **us-east-2**, in the **CTMS Travel** org. Staging was
created 14 Sep and is deliberately **empty** — the schema arrives in session 02
as versioned migrations, which is the whole point of doing migrations before
schema v1.

`FETCH_ENV` is set per context in `netlify.toml`, not in the Netlify UI, so it
lives in the repo and travels with a branch.

Branch deploys are limited to `staging` alone. Not "all branches": every
feature branch getting a public URL against the staging database is how
fictional bookings carrying real property names end up indexed.

## Variables

| Key | Context | Scope | Value | Status |
|---|---|---|---|---|
| `SB_URL` | production | builds, functions | `https://sqzuvtshebrgzivyzyif.supabase.co` | **set 14 Sep** |
| `SB_KEY` | production | builds, functions | production publishable key | **set 14 Sep** |
| `SB_URL` | branch-deploy | builds, functions | `https://crvuzehuiluoxqehtcta.supabase.co` | **set 14 Sep** |
| `SB_KEY` | branch-deploy | builds, functions | staging publishable key | **set 14 Sep** |
| `SB_URL` | deploy-preview | builds, functions | `https://crvuzehuiluoxqehtcta.supabase.co` | **set 14 Sep** |
| `SB_KEY` | deploy-preview | builds, functions | staging publishable key | **set 14 Sep** |
| `SUPABASE_SERVICE_ROLE_KEY` | per context | **functions only** | staging / production secret key | not set — nothing needs it yet |

The project had **zero** environment variables before 14 Sep, so nothing was
overwritten. All six values are live in Netlify and verified; the key values
themselves are not repeated in this file, because a doc is a worse place to
keep a credential than the place that already holds it.

### The one that can hurt you

`SUPABASE_SERVICE_ROLE_KEY` must be scoped to **Functions only**, never Builds.
A variable with the Builds scope can be read by anything running at build time
and end up inside a file the browser downloads, and nothing warns you. It is
not set today, and nothing should set it until an edge function needs it
(sessions 06 and 08 are the first).

`SB_KEY` is different and is not a secret. It is a `sb_publishable_…` key — the
anon-equivalent, public by design. It is safe in a build because it is already
public: it sits in the page source of four files in a public repo.

## What actually protects the data

Not the key. Row-level security.

`schema.sql` enables RLS on every table, but the policies are
`for all using (true) with check (true)` on `network_properties`, `tags`,
`bookings`, `leads`, `clicks` and `tag_content`. Combined with a publishable
key that everyone has, that means anyone can read, insert or delete any demo
row. Two consequences worth stating plainly:

- The demo data is fictional, so this is embarrassing rather than harmful.
- `go.html` inserts into `clicks` from the browser on that key, so **tap counts
  are forgeable by anyone who reads the page source**. Taps are a number FETCH
  intends to report, and the moat is the dataset, so this is a data-integrity
  problem, not only a security one.

Tightening those policies breaks every write path in the console, because they
all run from the browser on that key. That is what **session 04** is for, and it
is the argument for pulling session 04 forward.

## Where the credentials live today

Hardcoded, as literals, in four files:

- `index.html` (line ~658)
- `creator.html` (line ~152)
- `property.html` (line ~156)
- `go.html` (line ~25)

The Setup tab in `app.html` is an **override** stored in `localStorage`
(`fetch_sb_url`, `fetch_sb_key`), not the source. An earlier note in the
roadmap said the *service key* is pasted into the Setup tab. Neither half is
right: it is the publishable key, and it is not pasted at runtime at all.

## There is a build step

`build.py` (and `_build/build.py`, `_build/mkpage.sh`) stamps the shared nav and
footer into every page between `<!--NAV-->` and `<!--FOOT-->` markers. Its
output is already committed, which is why `netlify.toml` sets no build command
— running it at deploy time would be a no-op.

This matters for the open client-credential decision. Option (a) — stamp
`SB_URL` and `SB_KEY` from the environment at deploy time and drop the Setup
tab's input fields — is nearly free, because the stamping script already exists
and only needs two more markers. Option (b), moving every read behind an edge
function so the browser holds no credential at all, is strictly tighter but
rewrites both dashboards on top of the sessions that build them.

Recommendation on file: **(a)**, with (b) kept for the write paths that must not
be forgeable — pixel intake, promo redemption, payout triggers — which are edge
functions in the plan already.

Note that `build.py` currently rewrites files **in place**. Under option (a) the
source files carry placeholders and the stamped output is produced at deploy
time; a stamped credential must never be committed back.

## Short-link host

Session 01 makes the host a variable rather than a literal, so no code moves
when a domain is finally bought. A configurable host is not the same thing as a
domain that resolves, so this does not settle the Phase 0 gate — see
`docs/session-01-apply.md`.
