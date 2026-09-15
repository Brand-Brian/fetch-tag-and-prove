-- FETCH — create the waitlist table.
-- index.html has always inserted into `waitlist`, but the table was never
-- created, so no signup from either form has ever been recorded.
--
-- Insert-only on purpose, and deliberately WITHOUT the policies in admin.sql
-- (select using true) and manage.sql (update using true). The publishable key
-- is in the page source of a public repo, so those would make every real name
-- and email address readable and editable by anyone. Read signups in the
-- dashboard until session 04 lands auth.

create table if not exists waitlist (
  id                 uuid primary key default gen_random_uuid(),
  kind               text not null check (kind in ('creator','property')),
  name               text,
  email              text not null,
  handle_or_property text,
  region             text,
  status             text not null default 'new',
  created_at         timestamptz default now()
);

alter table waitlist enable row level security;

drop policy if exists "waitlist insert" on waitlist;
create policy "waitlist insert" on waitlist
  for insert
  with check (true);
