-- FETCH — top up any link that has no history yet
-- Paste into Supabase: SQL Editor → New query → Run.
--
-- The demo network is fully seeded, but any tag added by hand (a real
-- creator, a real property) still shows an empty dashboard. This gives
-- every such tag a plausible history so nothing lands blank.
--
-- Only ever ADDS, never deletes. Re-running is safe: a tag that already
-- has taps or bookings is skipped.
-- Everything it writes to bookings is marked notes = 'demo-topup'.

begin;

-- ---------- taps for any tag with none ----------
insert into clicks (code, clicked_at)
select i.code, now() - ((random() * 52) || ' days')::interval - ((random() * 22) || ' hours')::interval
from (
  select t.code
  from tags t
  left join clicks c on c.code = t.code
  group by t.code
  having count(c.id) = 0
) i
cross join lateral generate_series(1, 90 + floor(random() * 220)::int);

-- ---------- bookings for any tag with none ----------
insert into bookings (code, booking_value, booked_on, checkout_date, status, verified_by, notes)
select
  b.code,
  b.value,
  current_date - b.booked_days,
  current_date - b.booked_days + b.stay_gap,
  case when b.booked_days - b.stay_gap > 12 then 'paid'
       when b.booked_days - b.stay_gap > 0  then 'verified'
       else 'reported' end,
  case when random() < 0.7 then 'pixel' else 'property_reported' end,
  'demo-topup'
from (
  select
    i.code,
    round((760 + random() * 1900)::numeric, 2)      as value,
    (14 + floor(random() * 34))::int                as booked_days,
    (6  + floor(random() * 16))::int                as stay_gap
  from (
    select t.code
    from tags t
    left join bookings bk on bk.code = t.code
    group by t.code
    having count(bk.id) = 0
  ) i
  cross join lateral generate_series(1, 2 + floor(random() * 4)::int)
) b;

-- ---------- payout dates on anything now marked paid ----------
update bookings set paid_at = checkout_date
where notes = 'demo-topup' and status = 'paid' and paid_at is null;

-- ---------- content detail for any tag missing it ----------
update tags set
  content_format = coalesce(content_format,
    (array['Reel','Carousel','Story set','TikTok'])[1 + floor(random() * 4)::int]),
  content_label = coalesce(content_label,
    (array['the room tour','first light','why we came back','off-season guide',
           'storm season','a local''s guide','the drive in','one night here'])[1 + floor(random() * 8)::int]),
  posted_on = coalesce(posted_on, current_date - (16 + floor(random() * 42))::int)
where content_format is null or content_label is null or posted_on is null;

commit;

-- To remove only what this added:
--   delete from bookings where notes = 'demo-topup';
--   (taps are indistinguishable from real ones by design — clear per code if needed)
