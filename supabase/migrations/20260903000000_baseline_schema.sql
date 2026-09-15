-- FETCH — baseline schema
-- Session 02, 15 September 2026.
--
-- This is the state of the production project (sqzuvtshebrgzivyzyif) as it stood
-- on 15 Sep 2026, reverse-engineered from the live database rather than from the
-- loose .sql files in the repo root. Where the two disagreed, the database won.
--
-- It is a FAITHFUL DUMP, not a corrected one. Two known-bad things are reproduced
-- here on purpose, because staging is only useful if it is a mirror:
--   1. Every policy is `for all using (true) with check (true)` — wide open.
--   2. The click views run with definer rights and ignore RLS (see the views
--      migration, and 20260915_pending_security_invoker_views.sql).
-- Both are session 04's job, and session 04 fixes them in BOTH projects.
--
-- Deliberately NOT included: the demo/seed data. Staging starts empty.
-- `waitlist` is not here either — it has its own migration, 20260914174506,
-- which is where it was really created.

begin;

-- ---------------------------------------------------------------- properties

create table if not exists public.network_properties (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  region        text,
  type          text default 'property'::text,
  booking_url   text,
  contact_name  text,
  contact_email text,
  created_at    timestamptz default now()
);

-- ---------------------------------------------------------------------- tags

create table if not exists public.tags (
  id             uuid primary key default gen_random_uuid(),
  creator_handle text not null,
  property_id    uuid references public.network_properties(id) on delete cascade,
  code           text not null unique,
  tracked_url    text not null,
  content_url    text,
  created_at     timestamptz default now(),
  content_format text,
  content_label  text,
  posted_on      date
);

-- ------------------------------------------------------------------ bookings

-- creator_amount and fetch_amount are STORED GENERATED columns, not defaults.
-- The 5/5 split is enforced by the database and cannot be overridden by an
-- insert — which is the point. Commission math is a non-negotiable, so it does
-- not live in application code where a caller can pass its own number.
--
-- THE THREE MONEY COLUMNS ARE numeric(10,2), NOT bare numeric. The connector's
-- table listing reports them as "numeric" with the precision dropped, and the
-- first pass of this file believed it. Staging then accepted booking values
-- production would have rounded. Caught by fingerprinting the two databases
-- against each other; do not "simplify" these back to numeric.
--
-- KNOWN, NOT FIXED HERE — the split can exceed the charge by a cent. Both
-- columns round independently, so for half of all possible booking values
-- creator_amount + fetch_amount is $0.01 more than round(booking_value*0.10,2)
-- — the 10% the property is actually charged. Verified over every cent from
-- $50.00 to $9,999.99: 497,500 of 995,000 values affected, always by exactly
-- one cent. Harmless while nothing charges a card; it is a ledger-balancing
-- problem in session 28, and session 35's gate is "the ledger balances".
-- The fix is to make one side the remainder rather than a second rounding:
--   fetch_amount = round(booking_value*0.10,2) - creator_amount
-- which keeps the creator's 5% whole and never overpays the pair. Left alone
-- here because session 02 reproduces production, and changing commission math
-- is Brian's call, not a migration's.
create table if not exists public.bookings (
  id             uuid primary key default gen_random_uuid(),
  tag_id         uuid references public.tags(id) on delete set null,
  code           text not null,
  booking_value  numeric(10,2) not null check (booking_value > 0),
  currency       text default 'CAD'::text,
  booked_on      date default current_date,
  verified_by    text default 'property_reported'::text,
  creator_amount numeric(10,2) generated always as (round(booking_value * 0.05, 2)) stored,
  fetch_amount   numeric(10,2) generated always as (round(booking_value * 0.05, 2)) stored,
  notes          text,
  created_at     timestamptz default now(),
  checkout_date  date,
  status         text not null default 'reported'::text,
  paid_at        date
);

-- --------------------------------------------------------------- tag_content

create table if not exists public.tag_content (
  id          uuid primary key default gen_random_uuid(),
  tag_id      uuid references public.tags(id) on delete cascade,
  content_url text not null,
  created_at  timestamptz default now()
);

-- --------------------------------------------------------------------- leads

create table if not exists public.leads (
  id             uuid primary key default gen_random_uuid(),
  content_url    text not null,
  creator_handle text,
  note           text,
  created_at     timestamptz default now()
);

-- -------------------------------------------------------------------- clicks

-- No index on (code) or (clicked_at) in production as of 15 Sep, and the three
-- click views aggregate by code across what is already 3,766 rows. Reproduced
-- as-is; session 07 ("Click logging — clicks table and its indexes") is where
-- that gets fixed, in both projects.
create table if not exists public.clicks (
  id         uuid primary key default gen_random_uuid(),
  code       text not null,
  clicked_at timestamptz default now()
);

-- ------------------------------------------------------------ RLS + policies

alter table public.network_properties enable row level security;
alter table public.tags               enable row level security;
alter table public.bookings           enable row level security;
alter table public.tag_content        enable row level security;
alter table public.leads              enable row level security;
alter table public.clicks             enable row level security;

-- WIDE OPEN, ON PURPOSE, TEMPORARILY.
--
-- RLS is enabled on every table and every policy then allows everything. That is
-- protected in principle and open in practice: anyone holding the publishable
-- key — which is everyone, it is in the page source of a public repo — can read,
-- insert, update and delete any row in any of these tables.
--
-- Today that is embarrassing rather than harmful, because every row is fictional.
-- It stops being acceptable the moment a real booking or a real person's details
-- land in one of these tables. Session 04 replaces all six with owner-scoped
-- policies. Do not add a table to this list; add it with a real policy instead.

drop policy if exists "pilot open" on public.network_properties;
drop policy if exists "pilot open" on public.tags;
drop policy if exists "pilot open" on public.bookings;
drop policy if exists "pilot open" on public.tag_content;
drop policy if exists "pilot open" on public.leads;
drop policy if exists "pilot open" on public.clicks;

create policy "pilot open" on public.network_properties for all using (true) with check (true);
create policy "pilot open" on public.tags               for all using (true) with check (true);
create policy "pilot open" on public.bookings           for all using (true) with check (true);
create policy "pilot open" on public.tag_content        for all using (true) with check (true);
create policy "pilot open" on public.leads              for all using (true) with check (true);
create policy "pilot open" on public.clicks             for all using (true) with check (true);

commit;
