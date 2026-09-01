-- FETCH Tag & Prove — pilot schema
-- Run this once in Supabase: SQL Editor → New query → paste → Run

create extension if not exists "pgcrypto";

-- Properties and tour operators in the pilot network
create table if not exists network_properties (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  region text,
  type text default 'property',          -- property | tour_operator | dmc
  booking_url text,                       -- their own booking engine
  contact_name text,
  contact_email text,
  created_at timestamptz default now()
);

-- One tag = one creator/property pairing with its tracked link and code
create table if not exists tags (
  id uuid primary key default gen_random_uuid(),
  creator_handle text not null,           -- e.g. @coastalkate
  property_id uuid references network_properties(id) on delete cascade,
  code text unique not null,              -- e.g. FETCH-KATE-WICK-7Q2
  tracked_url text not null,              -- booking_url + ?ref=code
  content_url text,                       -- the Reel/TikTok, if known
  created_at timestamptz default now()
);

-- Verified bookings logged against a code
create table if not exists bookings (
  id uuid primary key default gen_random_uuid(),
  tag_id uuid references tags(id) on delete set null,
  code text not null,
  booking_value numeric(10,2) not null check (booking_value > 0),
  currency text default 'CAD',
  booked_on date default current_date,
  verified_by text default 'property_reported',  -- property_reported | pixel | webhook
  creator_amount numeric(10,2) generated always as (round(booking_value * 0.05, 2)) stored,
  fetch_amount numeric(10,2) generated always as (round(booking_value * 0.05, 2)) stored,
  notes text,
  created_at timestamptz default now()
);

-- Leads: someone checked a video that isn't in the network yet
create table if not exists leads (
  id uuid primary key default gen_random_uuid(),
  content_url text not null,
  creator_handle text,
  note text,
  created_at timestamptz default now()
);

-- Pilot-grade access: open to the anon key.
-- Fine for a hand-run pilot with a handful of trusted users.
-- Lock this down with real auth before creator self-serve (months 3-9).
alter table network_properties enable row level security;
alter table tags enable row level security;
alter table bookings enable row level security;
alter table leads enable row level security;

create policy "pilot open" on network_properties for all using (true) with check (true);
create policy "pilot open" on tags for all using (true) with check (true);
create policy "pilot open" on bookings for all using (true) with check (true);
create policy "pilot open" on leads for all using (true) with check (true);
