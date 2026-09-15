-- FETCH — click aggregate views
-- Session 02, 15 September 2026. Faithful dump of production.
--
-- WHY THESE EXIST: PostgREST caps a plain select at 1000 rows. Both dashboards
-- used to fetch the raw `clicks` table, so past 1000 taps the first creator
-- absorbed the cap and every other creator read zero. Taps come from these
-- views instead. (Found and fixed 3 Sep. `bookings` has the same ceiling and
-- has not had the same treatment — it is at 61 rows, so it has not bitten yet.)
--
-- WHY THEY ARE A LANDMINE: these are created without `security_invoker`, so on
-- Postgres 15+ they run with the VIEW OWNER's permissions, not the caller's —
-- they ignore RLS entirely. Supabase's security advisor flags all three at
-- ERROR level.
--
-- That is harmless today only because the underlying policy on `clicks` is
-- `using (true)` anyway, so there is nothing for the view to bypass. The moment
-- session 04 tightens those policies, these three views keep returning every
-- creator's click data to anyone who asks, straight past the new rules, and
-- nothing warns you. The new policies would look correct and be inert.
--
-- So: fix them in the SAME session 04 pass as the policies, not after.
-- The fix is written and waiting, unapplied, in
--   20260915_pending_security_invoker_views.sql
-- Reproduced as-is here so staging mirrors production.
-- https://supabase.com/docs/guides/database/database-linter?lint=0010_security_definer_view

begin;

create or replace view public.click_counts as
  select code,
         count(*)::integer as taps
    from public.clicks
   group by code;

create or replace view public.click_weeks as
  select code,
         (date_trunc('week', clicked_at))::date as week,
         count(*)::integer as taps
    from public.clicks
   group by code, (date_trunc('week', clicked_at))::date;

create or replace view public.click_months as
  select code,
         to_char(clicked_at, 'YYYY-MM') as month,
         count(*)::integer as taps
    from public.clicks
   group by code, to_char(clicked_at, 'YYYY-MM');

commit;
