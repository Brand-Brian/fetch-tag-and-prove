-- Waitlist signups from the FETCH website
-- Run once in Supabase: SQL Editor → New query → paste → Run

create table if not exists waitlist (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('creator','property')),
  name text,
  email text not null,
  handle_or_property text,      -- creator handle, or property/DMC name
  region text,
  created_at timestamptz default now()
);

alter table waitlist enable row level security;
-- Site visitors can sign up but can't read the list
create policy "waitlist insert" on waitlist for insert with check (true);
