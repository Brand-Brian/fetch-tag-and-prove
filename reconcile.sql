-- FETCH reconciliation upgrade
-- Run once in Supabase: SQL Editor → New query → paste → Run

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
