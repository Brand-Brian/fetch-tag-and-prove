-- FETCH — one-shot demo setup
-- Paste this whole file into Supabase: SQL Editor → New query → Run.
-- It runs reconcile, retro and content migrations, then seeds the demo network.
-- Safe to re-run.

-- ========== 1. reconcile.sql ==========

-- Every tap on a tracked link, before the redirect
create table if not exists clicks (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  clicked_at timestamptz default now()
);

-- Booking lifecycle: reported → verified (stay completed) → paid
alter table bookings add column if not exists checkout_date date;
alter table bookings add column if not exists status text not null default 'reported';
alter table bookings add column if not exists paid_at date;

alter table clicks enable row level security;
create policy "pilot open" on clicks for all using (true) with check (true);

-- ========== 2. retro.sql ==========
create table if not exists tag_content (
  id uuid primary key default gen_random_uuid(),
  tag_id uuid references tags(id) on delete cascade,
  content_url text not null,
  created_at timestamptz default now()
);
alter table tag_content enable row level security;
create policy "pilot open" on tag_content for all using (true) with check (true);

-- ========== 3. content.sql ==========

alter table tags add column if not exists content_format text;   -- Reel | Carousel | Story set | TikTok
alter table tags add column if not exists content_label  text;   -- short human descriptor, e.g. "storm season"
alter table tags add column if not exists posted_on      date;   -- when the creator published it

-- ========== 4. seed.sql ==========
-- Safe to re-run: it clears its own rows first (everything it writes is prefixed
-- FETCH-DEMO- or marked notes = 'demo-seed').

begin;

-- ---------- clear any previous run ----------
delete from tag_content where tag_id in (select id from tags where code like 'FETCH-DEMO-%');
delete from clicks     where code like 'FETCH-DEMO-%';
delete from bookings   where code like 'FETCH-DEMO-%';
delete from tags       where code like 'FETCH-DEMO-%';
delete from network_properties where id in (
  '0d000001-0000-4000-8000-000000000001','0d000001-0000-4000-8000-000000000002',
  '0d000001-0000-4000-8000-000000000003','0d000001-0000-4000-8000-000000000004',
  '0d000001-0000-4000-8000-000000000005','0d000001-0000-4000-8000-000000000006',
  '0d000001-0000-4000-8000-000000000007','0d000001-0000-4000-8000-000000000008',
  '0d000001-0000-4000-8000-000000000009','0d000001-0000-4000-8000-00000000000a',
  '0d000001-0000-4000-8000-00000000000b');

-- ---------- 11 properties, one corridor ----------
insert into network_properties (id, name, region, type, booking_url, contact_name, contact_email) values
 ('0d000001-0000-4000-8000-000000000001','Cedar Point Lodge','Tofino, BC','property','https://example.com/cedar-point/book','Nora Feltham','stay@example.com'),
 ('0d000001-0000-4000-8000-000000000002','Driftline Domes','Tofino, BC','property','https://example.com/driftline/book','Ari Nakashima','hello@example.com'),
 ('0d000001-0000-4000-8000-000000000003','Quiet Cove Suites','Ucluelet, BC','property','https://example.com/quiet-cove/book','Dana Oyelaran','front@example.com'),
 ('0d000001-0000-4000-8000-000000000004','Ridgeback Chalets','Ucluelet, BC','property','https://example.com/ridgeback/book','Sam Petrov','book@example.com'),
 ('0d000001-0000-4000-8000-000000000005','Wolf Eel Cabins','Ucluelet, BC','property','https://example.com/wolf-eel/book','Junie Marchand','stay@example.com'),
 ('0d000001-0000-4000-8000-000000000006','The Storm House','Tofino, BC','property','https://example.com/storm-house/book','Ellis Rhodes','hello@example.com'),
 ('0d000001-0000-4000-8000-000000000007','Mist Harbour Lodge','Tofino, BC','property','https://example.com/mist-harbour/book','Priya Sandhu','reception@example.com'),
 ('0d000001-0000-4000-8000-000000000008','Kelp Line Cottages','Ucluelet, BC','property','https://example.com/kelp-line/book','Tom Beaudry','book@example.com'),
 ('0d000001-0000-4000-8000-000000000009','Longshore Inn','Ucluelet, BC','property','https://example.com/longshore/book','Kit Alvarez','stay@example.com'),
 ('0d000001-0000-4000-8000-00000000000a','Tidepool Guesthouse','Tofino, BC','property','https://example.com/tidepool/book','Marguerite Poole','hello@example.com'),
 ('0d000001-0000-4000-8000-00000000000b','Salal & Sea','Tofino, BC','property','https://example.com/salal-sea/book','Wren Okafor','stay@example.com');

-- ---------- 6 creators, 22 tags ----------
insert into tags (id, creator_handle, property_id, code, tracked_url, content_url) values
 ('0d000002-0000-4000-8000-000000000001','@coastlinescout','0d000001-0000-4000-8000-000000000001','FETCH-DEMO-SCOUT-CEDR','https://example.com/cedar-point/book?ref=FETCH-DEMO-SCOUT-CEDR','https://www.instagram.com/reel/DEMOscout1/'),
 ('0d000002-0000-4000-8000-000000000002','@coastlinescout','0d000001-0000-4000-8000-000000000002','FETCH-DEMO-SCOUT-DRFT','https://example.com/driftline/book?ref=FETCH-DEMO-SCOUT-DRFT','https://www.instagram.com/reel/DEMOscout2/'),
 ('0d000002-0000-4000-8000-000000000003','@coastlinescout','0d000001-0000-4000-8000-000000000003','FETCH-DEMO-SCOUT-QUIE','https://example.com/quiet-cove/book?ref=FETCH-DEMO-SCOUT-QUIE','https://www.instagram.com/p/DEMOscout3/'),
 ('0d000002-0000-4000-8000-000000000004','@coastlinescout','0d000001-0000-4000-8000-000000000005','FETCH-DEMO-SCOUT-WOLF','https://example.com/wolf-eel/book?ref=FETCH-DEMO-SCOUT-WOLF','https://www.instagram.com/reel/DEMOscout4/'),
 ('0d000002-0000-4000-8000-000000000005','@coastlinescout','0d000001-0000-4000-8000-000000000006','FETCH-DEMO-SCOUT-STRM','https://example.com/storm-house/book?ref=FETCH-DEMO-SCOUT-STRM',null),
 ('0d000002-0000-4000-8000-000000000006','@coastlinescout','0d000001-0000-4000-8000-000000000008','FETCH-DEMO-SCOUT-KELP','https://example.com/kelp-line/book?ref=FETCH-DEMO-SCOUT-KELP','https://www.tiktok.com/@demo/video/700001'),
 ('0d000002-0000-4000-8000-000000000007','@saltandcedar','0d000001-0000-4000-8000-000000000001','FETCH-DEMO-SALT-CEDR','https://example.com/cedar-point/book?ref=FETCH-DEMO-SALT-CEDR','https://www.instagram.com/reel/DEMOsalt1/'),
 ('0d000002-0000-4000-8000-000000000008','@saltandcedar','0d000001-0000-4000-8000-000000000004','FETCH-DEMO-SALT-RIDG','https://example.com/ridgeback/book?ref=FETCH-DEMO-SALT-RIDG','https://www.instagram.com/reel/DEMOsalt2/'),
 ('0d000002-0000-4000-8000-000000000009','@saltandcedar','0d000001-0000-4000-8000-000000000007','FETCH-DEMO-SALT-MIST','https://example.com/mist-harbour/book?ref=FETCH-DEMO-SALT-MIST','https://www.tiktok.com/@demo/video/700002'),
 ('0d000002-0000-4000-8000-00000000000a','@saltandcedar','0d000001-0000-4000-8000-000000000009','FETCH-DEMO-SALT-LONG','https://example.com/longshore/book?ref=FETCH-DEMO-SALT-LONG',null),
 ('0d000002-0000-4000-8000-00000000000b','@lowtidediaries','0d000001-0000-4000-8000-000000000001','FETCH-DEMO-LOWT-CEDR','https://example.com/cedar-point/book?ref=FETCH-DEMO-LOWT-CEDR','https://www.instagram.com/reel/DEMOlow1/'),
 ('0d000002-0000-4000-8000-00000000000c','@lowtidediaries','0d000001-0000-4000-8000-000000000004','FETCH-DEMO-LOWT-RIDG','https://example.com/ridgeback/book?ref=FETCH-DEMO-LOWT-RIDG','https://www.instagram.com/reel/DEMOlow2/'),
 ('0d000002-0000-4000-8000-00000000000d','@lowtidediaries','0d000001-0000-4000-8000-000000000002','FETCH-DEMO-LOWT-DRFT','https://example.com/driftline/book?ref=FETCH-DEMO-LOWT-DRFT','https://www.tiktok.com/@demo/video/700003'),
 ('0d000002-0000-4000-8000-00000000000e','@westofhere','0d000001-0000-4000-8000-000000000003','FETCH-DEMO-WEST-QUIE','https://example.com/quiet-cove/book?ref=FETCH-DEMO-WEST-QUIE','https://www.instagram.com/reel/DEMOwest1/'),
 ('0d000002-0000-4000-8000-00000000000f','@westofhere','0d000001-0000-4000-8000-000000000001','FETCH-DEMO-WEST-CEDR','https://example.com/cedar-point/book?ref=FETCH-DEMO-WEST-CEDR',null),
 ('0d000002-0000-4000-8000-000000000010','@westofhere','0d000001-0000-4000-8000-000000000005','FETCH-DEMO-WEST-WOLF','https://example.com/wolf-eel/book?ref=FETCH-DEMO-WEST-WOLF','https://www.instagram.com/p/DEMOwest2/'),
 ('0d000002-0000-4000-8000-000000000011','@fogandfern','0d000001-0000-4000-8000-000000000004','FETCH-DEMO-FOGF-RIDG','https://example.com/ridgeback/book?ref=FETCH-DEMO-FOGF-RIDG','https://www.instagram.com/reel/DEMOfog1/'),
 ('0d000002-0000-4000-8000-000000000012','@fogandfern','0d000001-0000-4000-8000-000000000007','FETCH-DEMO-FOGF-MIST','https://example.com/mist-harbour/book?ref=FETCH-DEMO-FOGF-MIST','https://www.tiktok.com/@demo/video/700004'),
 ('0d000002-0000-4000-8000-000000000013','@fogandfern','0d000001-0000-4000-8000-00000000000a','FETCH-DEMO-FOGF-TIDE','https://example.com/tidepool/book?ref=FETCH-DEMO-FOGF-TIDE',null),
 ('0d000002-0000-4000-8000-000000000014','@thegreyferry','0d000001-0000-4000-8000-000000000002','FETCH-DEMO-GREY-DRFT','https://example.com/driftline/book?ref=FETCH-DEMO-GREY-DRFT','https://www.instagram.com/reel/DEMOgrey1/'),
 ('0d000002-0000-4000-8000-000000000015','@thegreyferry','0d000001-0000-4000-8000-000000000006','FETCH-DEMO-GREY-STRM','https://example.com/storm-house/book?ref=FETCH-DEMO-GREY-STRM','https://www.tiktok.com/@demo/video/700005'),
 ('0d000002-0000-4000-8000-000000000016','@thegreyferry','0d000001-0000-4000-8000-00000000000b','FETCH-DEMO-GREY-SALA','https://example.com/salal-sea/book?ref=FETCH-DEMO-GREY-SALA',null);

-- ---------- extra back-catalogue content on some tags ----------
insert into tag_content (tag_id, content_url) values
 ('0d000002-0000-4000-8000-000000000001','https://www.tiktok.com/@demo/video/700010'),
 ('0d000002-0000-4000-8000-000000000001','https://www.instagram.com/p/DEMOscout1b/'),
 ('0d000002-0000-4000-8000-000000000007','https://www.instagram.com/p/DEMOsalt1b/'),
 ('0d000002-0000-4000-8000-00000000000b','https://www.tiktok.com/@demo/video/700011'),
 ('0d000002-0000-4000-8000-000000000011','https://www.instagram.com/p/DEMOfog1b/');

-- ---------- taps, spread across the last 8 weeks ----------
insert into clicks (code, clicked_at)
select c.code, now() - ((random() * 55) || ' days')::interval - ((random() * 20) || ' hours')::interval
from (values
  ('FETCH-DEMO-SCOUT-CEDR',487),('FETCH-DEMO-SCOUT-DRFT',302),('FETCH-DEMO-SCOUT-QUIE',188),
  ('FETCH-DEMO-SCOUT-WOLF',121),('FETCH-DEMO-SCOUT-STRM',76),('FETCH-DEMO-SCOUT-KELP',30),
  ('FETCH-DEMO-SALT-CEDR',640),('FETCH-DEMO-SALT-RIDG',214),('FETCH-DEMO-SALT-MIST',163),('FETCH-DEMO-SALT-LONG',58),
  ('FETCH-DEMO-LOWT-CEDR',201),('FETCH-DEMO-LOWT-RIDG',147),('FETCH-DEMO-LOWT-DRFT',96),
  ('FETCH-DEMO-WEST-QUIE',134),('FETCH-DEMO-WEST-CEDR',88),('FETCH-DEMO-WEST-WOLF',71),
  ('FETCH-DEMO-FOGF-RIDG',119),('FETCH-DEMO-FOGF-MIST',84),('FETCH-DEMO-FOGF-TIDE',43),
  ('FETCH-DEMO-GREY-DRFT',157),('FETCH-DEMO-GREY-STRM',92),('FETCH-DEMO-GREY-SALA',26)
) as c(code, n)
cross join lateral generate_series(1, c.n);

-- ---------- bookings: paid, verified (stay done, payout pending), reported (upcoming) ----------
insert into bookings (code, booking_value, booked_on, checkout_date, status, verified_by, notes) values
 ('FETCH-DEMO-SCOUT-CEDR',2340.00, current_date-41, current_date-27,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-CEDR',3420.00, current_date-38, current_date-22,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-CEDR',2360.00, current_date-33, current_date-18,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-CEDR',1980.00, current_date-24, current_date-9,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-CEDR',2210.00, current_date-16, current_date-2,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-CEDR',2190.00, current_date-9,  current_date+12,'reported','property_reported','demo-seed'),
 ('FETCH-DEMO-SCOUT-CEDR',1740.00, current_date-4,  current_date+21,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-DRFT',1180.00, current_date-35, current_date-20,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-DRFT',1180.00, current_date-29, current_date-14,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-DRFT',1420.00, current_date-18, current_date-3,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-DRFT',1180.00, current_date-6,  current_date+16,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-QUIE',1760.00, current_date-31, current_date-16,'paid','property_reported','demo-seed'),
 ('FETCH-DEMO-SCOUT-QUIE',1540.00, current_date-20, current_date-5,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-QUIE',1290.00, current_date-7,  current_date+18,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-WOLF',1120.00, current_date-22, current_date-7,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-WOLF',820.00,  current_date-5,  current_date+23,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-SCOUT-STRM',820.00,  current_date-3,  current_date+26,'reported','property_reported','demo-seed'),
 ('FETCH-DEMO-SALT-CEDR',1560.00, current_date-30, current_date-15,'paid','property_reported','demo-seed'),
 ('FETCH-DEMO-SALT-CEDR',1420.00, current_date-11, current_date+9,'reported','property_reported','demo-seed'),
 ('FETCH-DEMO-SALT-RIDG',2140.00, current_date-36, current_date-21,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-SALT-RIDG',1880.00, current_date-19, current_date-4,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-SALT-RIDG',1650.00, current_date-8,  current_date+14,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-SALT-MIST',1340.00, current_date-26, current_date-11,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-SALT-MIST',1120.00, current_date-12, current_date+7,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-SALT-LONG',760.00,  current_date-15, current_date-1,'verified','property_reported','demo-seed'),
 ('FETCH-DEMO-LOWT-CEDR',2610.00, current_date-28, current_date-13,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-LOWT-CEDR',1520.00, current_date-21, current_date-6,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-LOWT-CEDR',1980.00, current_date-10, current_date+11,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-LOWT-CEDR',1460.00, current_date-2,  current_date+29,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-LOWT-RIDG',1720.00, current_date-34, current_date-19,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-LOWT-RIDG',1390.00, current_date-17, current_date-2,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-LOWT-RIDG',1240.00, current_date-6,  current_date+17,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-LOWT-DRFT',1080.00, current_date-23, current_date-8,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-LOWT-DRFT',940.00,  current_date-4,  current_date+22,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-WEST-QUIE',1840.00, current_date-32, current_date-17,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-WEST-QUIE',1610.00, current_date-14, current_date+1,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-WEST-CEDR',1880.00, current_date-25, current_date-10,'paid','property_reported','demo-seed'),
 ('FETCH-DEMO-WEST-CEDR',1520.00, current_date-9,  current_date+13,'reported','property_reported','demo-seed'),
 ('FETCH-DEMO-WEST-WOLF',980.00,  current_date-13, current_date+2,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-FOGF-RIDG',2050.00, current_date-27, current_date-12,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-FOGF-RIDG',1780.00, current_date-15, current_date,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-FOGF-RIDG',1430.00, current_date-5,  current_date+19,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-FOGF-MIST',1260.00, current_date-18, current_date-3,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-FOGF-MIST',1100.00, current_date-3,  current_date+25,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-FOGF-TIDE',690.00,  current_date-11, current_date+4,'reported','property_reported','demo-seed'),
 ('FETCH-DEMO-GREY-DRFT',1240.00, current_date-37, current_date-23,'paid','pixel','demo-seed'),
 ('FETCH-DEMO-GREY-DRFT',1180.00, current_date-19, current_date-5,'verified','pixel','demo-seed'),
 ('FETCH-DEMO-GREY-DRFT',1320.00, current_date-7,  current_date+15,'reported','pixel','demo-seed'),
 ('FETCH-DEMO-GREY-STRM',960.00,  current_date-16, current_date-1,'verified','property_reported','demo-seed'),
 ('FETCH-DEMO-GREY-STRM',880.00,  current_date-2,  current_date+27,'reported','property_reported','demo-seed'),
 ('FETCH-DEMO-GREY-SALA',740.00,  current_date-8,  current_date+20,'reported','pixel','demo-seed');

-- stamp the payout date on everything already paid
update bookings set paid_at = checkout_date
where code like 'FETCH-DEMO-%' and status = 'paid' and paid_at is null;

-- ---------- what each piece of content actually was ----------
-- Requires content.sql to have been run first.
update tags t set
  content_format = v.fmt,
  content_label  = v.lbl,
  posted_on      = current_date - v.days
from (values
  ('FETCH-DEMO-SCOUT-CEDR','Reel','storm season',52),
  ('FETCH-DEMO-SCOUT-DRFT','Reel','one night in a dome',44),
  ('FETCH-DEMO-SCOUT-QUIE','Carousel','where to stay',39),
  ('FETCH-DEMO-SCOUT-WOLF','Reel','rainforest walk',30),
  ('FETCH-DEMO-SCOUT-STRM','Story set','3 frames',12),
  ('FETCH-DEMO-SCOUT-KELP','TikTok','off-season guide',7),
  ('FETCH-DEMO-SALT-CEDR','Reel','the drive in',48),
  ('FETCH-DEMO-SALT-RIDG','Reel','cabin tour',43),
  ('FETCH-DEMO-SALT-MIST','TikTok','what $300 gets you',33),
  ('FETCH-DEMO-SALT-LONG','Carousel','harbour morning',22),
  ('FETCH-DEMO-LOWT-CEDR','Reel','surf check',36),
  ('FETCH-DEMO-LOWT-RIDG','Reel','fireplace and fog',41),
  ('FETCH-DEMO-LOWT-DRFT','TikTok','dome at night',28),
  ('FETCH-DEMO-WEST-QUIE','Reel',E'a local\'s guide',40),
  ('FETCH-DEMO-WEST-CEDR','Story set','4 frames',31),
  ('FETCH-DEMO-WEST-WOLF','Carousel','the trail behind',19),
  ('FETCH-DEMO-FOGF-RIDG','Reel','rain day',35),
  ('FETCH-DEMO-FOGF-MIST','TikTok','breakfast view',24),
  ('FETCH-DEMO-FOGF-TIDE','Carousel','tidepools at dawn',16),
  ('FETCH-DEMO-GREY-DRFT','Reel','ferry to the coast',46),
  ('FETCH-DEMO-GREY-STRM','TikTok','storm watching',21),
  ('FETCH-DEMO-GREY-SALA','Reel','four suites, one beach',11)
) as v(code, fmt, lbl, days)
where t.code = v.code;


commit;

-- To remove this demo data later:
--   delete from tag_content where tag_id in (select id from tags where code like 'FETCH-DEMO-%');
--   delete from clicks   where code like 'FETCH-DEMO-%';
--   delete from bookings where code like 'FETCH-DEMO-%';
--   delete from tags     where code like 'FETCH-DEMO-%';
--   delete from network_properties where name in ('Cedar Point Lodge','Driftline Domes','Quiet Cove Suites','Ridgeback Chalets','Wolf Eel Cabins','The Storm House','Mist Harbour Lodge','Kelp Line Cottages','Longshore Inn','Tidepool Guesthouse','Salal & Sea');
