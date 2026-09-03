-- FETCH — aggregate views for taps
-- Paste into Supabase: SQL Editor → New query → Run.
--
-- Why: PostgREST caps a plain select at 1000 rows. The dashboards were
-- fetching the raw clicks table, so past 1000 taps the numbers silently
-- went wrong — one creator absorbed the whole cap and the rest showed
-- zero. These views return one row per code (and per week, per month),
-- so the counts stay correct no matter how many taps accumulate.

create or replace view click_counts as
  select code, count(*)::int as taps
  from clicks group by code;

create or replace view click_weeks as
  select code,
         (date_trunc('week', clicked_at))::date as week,
         count(*)::int as taps
  from clicks group by code, 2;

create or replace view click_months as
  select code,
         to_char(clicked_at, 'YYYY-MM') as month,
         count(*)::int as taps
  from clicks group by code, 2;

grant select on click_counts, click_weeks, click_months to anon, authenticated;
