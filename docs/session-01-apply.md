# Session 01 — apply runbook

Everything in this file needs an account Claude cannot reach from a cloud
session. Work top to bottom; each step says how to tell it worked.

Status as of **14 September 2026**.

---

## Already done — no action needed

Done directly through the Netlify and Supabase connectors, which reach both
services from a cloud session. (A pasted Supabase *access token* would not have
worked: the sandbox shell cannot reach `supabase.com` at all. Connector traffic
routes outside it.)

**`waitlist` created in production**, as migration `create_waitlist_insert_only`
— insert-only, `status` column included, and without the `admin.sql` /
`manage.sql` policies. Verified by role rather than assumed: as `anon` the
insert succeeds and a select back returns **0 rows**, which is exactly the
intended shape. Test row deleted. **Signups on the live site now record for the
first time.**

**`fetch-staging` created** — ref `crvuzehuiluoxqehtcta`, us-east-2, CTMS Travel
org, $10/month, approved by Brian 14 Sep. Deliberately empty: the schema arrives
in session 02 as versioned migrations.

**All six Netlify environment variables set and verified.** `SB_URL` and
`SB_KEY` across production, branch-deploy and deploy-preview, each scoped builds
+ functions. Full table in `docs/environments.md`.

**Checked while in there:** no tag in production has a `fetch.travel`
destination or points back at `/go.html`, and all 12 properties have a booking
URL — so the two link bugs fixed in this session were latent, not live.

---

## 1. Create the `staging` branch — 1 minute

```bash
git checkout main && git pull
git checkout -b staging
git push -u origin staging
```

Leave `SUPABASE_SERVICE_ROLE_KEY` unset. When it is eventually needed
(session 06 at the earliest) it is scoped **Functions only**, never Builds — a
Builds-scoped variable can end up inside a file the browser downloads and
nothing warns you.

## ~~2. Deploy contexts~~ — done 14 Sep

Confirmed set in Netlify → Build & deploy → Branches and deploy contexts:

- Production branch: `main`
- Branch deploys: `staging` only — **not** "All". Every feature branch getting a
  public URL against the staging database is how fictional bookings carrying
  real property names end up indexed by Google.
- Deploy previews: any pull request against the production branch / branch
  deploy branches

## 3. Land the session 01 commit — 2 minutes

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

**Checked 14 Sep against production — clean.** 23 tags, zero pointing at
`fetch.travel`, zero pointing back at `/go.html`, and all 12 properties have a
booking URL. Both bugs were latent. Worth re-running after the first property is
onboarded without a booking engine:

```sql
select code, tracked_url from tags
where tracked_url ilike '%fetch.travel%'
   or tracked_url ilike '%/go.html%';
```

**The click views ignore RLS.** Supabase's security advisor flags
`click_counts`, `click_weeks` and `click_months` as ERROR-level
`SECURITY DEFINER` views: they run with the creator's permissions, not the
querying user's. That changes nothing today, because every policy is
`using (true)` anyway. It matters in **session 04**: tighten the policies and
these views keep returning every creator's click data straight past them, with
no warning. Fix them in the same pass.
<https://supabase.com/docs/guides/database/database-linter?lint=0010_security_definer_view>
