# Session 01 — apply runbook

Everything in this file needs an account Claude cannot reach from a cloud
session. Work top to bottom; each step says how to tell it worked.

Status as of **14 September 2026**.

---

## Already done — no action needed

**Netlify production environment variables are set.** The project had zero
variables; nothing was overwritten.

| Key | Context | Scope | Value |
|---|---|---|---|
| `SB_URL` | production | builds, functions | `https://sqzuvtshebrgzivyzyif.supabase.co` |
| `SB_KEY` | production | builds, functions | production publishable key |

Both values are already public — they sit in the page source of four files in a
public repo — so setting them changed no exposure. They do nothing yet either:
nothing reads them until the build step stamps them, which is the open
client-credential decision. They are in place so the contract exists.

---

## 1. Apply `create-waitlist.sql` — 2 minutes

**Signups on the live site have never been recorded.** `index.html` inserts into
`waitlist`; the table does not exist in production.

Supabase dashboard → the production project (`sqzuvtshebrgzivyzyif`) → SQL
Editor → New query → paste `create-waitlist.sql` → Run.

**Do not run `admin.sql` or `manage.sql.`** Both are headed "run once in
Supabase" and read like setup steps. They add `for select using (true)` and
`for update using (true)` to a table about to hold real names and email
addresses, on a key the whole internet has. Read signups in the Supabase
dashboard until session 04. `create-waitlist.sql` already includes the `status`
column that `manage.sql` was there for.

**Worked when:** submit the creator form on the live site and the thank-you
message appears instead of *"That didn't save. Email brian@brand-tastic.ca and
you're in."* Then check Table Editor → `waitlist` for the row, and delete it.

## 2. Create the staging Supabase project — 10 minutes

Region should match production. The database password is not recoverable and
session 02 needs it — save it to your password manager, and do not reuse
production's.

```bash
supabase orgs list
supabase projects list          # note production's region
supabase projects create fetch-staging \
  --org-id <ORG_ID> \
  --region <SAME_REGION_AS_PRODUCTION> \
  --db-password '<A_FRESH_PASSWORD>'
supabase projects list          # note the new project ref
supabase projects api-keys --project-ref <STAGING_REF>
```

Send back the **project ref** and the **publishable / anon key**. Not the secret
key — it bypasses row-level security and nothing in session 01 or 02 needs it.

**Worked when:** the project shows Active in the dashboard and
`supabase projects list` includes it.

## 3. Create the `staging` branch — 1 minute

```bash
git checkout main && git pull
git checkout -b staging
git push -u origin staging
```

## 4. Set the staging Netlify variables — 3 minutes

Netlify → fetch-and-prove → Project configuration → Environment variables.

Add `SB_URL` and `SB_KEY` for **branch deploys** and **deploy previews**,
pointing at `fetch-staging`. Full contract in `docs/environments.md`.

Leave `SUPABASE_SERVICE_ROLE_KEY` unset. When it is eventually needed
(session 06 at the earliest) it is scoped **Functions only**, never Builds — a
Builds-scoped variable can end up inside a file the browser downloads and
nothing warns you.

## 5. Deploy contexts — 2 minutes

Netlify → Build & deploy → Deploy contexts:

- Deploy previews: **on** for pull requests
- Branch deploys: **let me add individual branches** → `staging` only

Not "all branches". Every feature branch getting a public URL against the
staging database is how fictional bookings carrying real property names end up
indexed by Google.

## 6. Land the session 01 commit — 2 minutes

The branch cannot be pushed from a cloud session: the repo is not in this
session's authorized set and there is no token. Either link a desktop session
to the machine holding the repo, or issue a fine-grained PAT (Contents:
read/write, Pull requests: read/write, this repo only, 7-day expiry).

**Worked when:** the PR opens a Netlify deploy preview, and that preview
responds with `X-Robots-Tag: noindex, nofollow`.

---

## Still a decision, not a task

**Client credentials — due before session 05.** Option (a): extend `build.py` to
stamp `SB_URL` and `SB_KEY` from the environment, browser keeps querying
Supabase under RLS, Setup tab loses its input fields. Option (b): every read
moves behind an edge function and the browser holds no credential — tighter,
but it rewrites both dashboards on top of the sessions that build them.
Recommendation on file is **(a)**, with (b) reserved for write paths that must
not be forgeable.

**The Phase 0 gate cannot pass as written — due Friday 18 September.** The gate
reads: *no credential is reachable from the browser, every table has an owner
and a policy, and the short-link domain resolves.* The domain was deferred on
4 September. Session 01 makes the host a variable (`GO_LINK_HOST`), so no code
moves when a domain is bought — but a configurable host is not a domain that
resolves. Gate definitions do not get reworded to fit what got built, so this is
a decision: either the domain clause is formally struck for the sandbox build,
or the domain gets bought this week.

---

## Found while doing this — worth a look

**Tags could be created with a destination FETCH does not own.** `app.html`
returned `https://fetch.travel/go/CODE` whenever a property had no booking URL,
and stored it as `tracked_url`. `creator.html` had the matching bug the other
way: it fell back to our own `/go.html?c=CODE`, and since `go.html` redirects to
whatever is in `tracked_url`, that is an infinite redirect loop. Both now refuse
to create the tag and say why.

**Worth checking once the database is reachable:** whether any existing row has
a `tracked_url` that points at `fetch.travel` or back at `/go.html`. Either way
those tags are dead links.

```sql
select code, tracked_url from tags
where tracked_url ilike '%fetch.travel%'
   or tracked_url ilike '%/go.html%';
```
