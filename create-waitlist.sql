-- FETCH — create the waitlist table
-- Run ONCE in the PRODUCTION Supabase project: SQL Editor → New query → Run.
--
-- Why this exists: index.html inserts signups into `waitlist`, but the table
-- was never created in production. A REST call returns
--   PGRST205  Could not find the table 'public.waitlist'
-- so every insert throws and the visitor sees the fallback message
-- ("That didn't save. Email brian@brand-tastic.ca and you're in.").
-- No signup from either form has ever been recorded.
--
-- This file replaces waitlist.sql + manage.sql for setup purposes. It is
-- waitlist.sql plus the `status` column, and DELIBERATELY WITHOUT the two
-- policies in admin.sql and manage.sql.
--
--   DO NOT RUN admin.sql OR manage.sql.
-- Both are headed "run once in Supabase" and read like setup steps. They add
--   admin.sql   →  for select using (true)
--   manage.sql  →  for update using (true) with check (true)
-- on a table that will hold real names and email addresses. The publishable
-- key is in the page source of four files in a public repo, so "true" means
-- anyone on the internet can read and edit every signup. They exist only to
-- make the Inbox tab in app.html work. Read signups in the Supabase dashboard
-- until session 04 puts auth and real policies in place.

create table if not exists waitlist (
  id                 uuid primary key default gen_random_uuid(),
  kind               text not null check (kind in ('creator','property')),
  name               text,
  email              text not null,
  handle_or_property text,          -- creator handle, or property/DMC name
  region             text,
  status             text not null default 'new',
  created_at         timestamptz default now()
);

alter table waitlist enable row level security;

-- Insert only. Visitors can sign up; nobody reading with the publishable key
-- can list, read, edit or delete what was submitted.
drop policy if exists "waitlist insert" on waitlist;
create policy "waitlist insert" on waitlist
  for insert
  with check (true);

-- Verify: the first should return a row, the second should return 0 rows
-- (not an error — RLS hides them, which is the point).
--
--   insert into waitlist (kind, email) values ('creator','test@example.com')
--     returning id;
--   select * from waitlist;   -- run this as anon, not in the SQL editor
--
-- Remember to delete the test row.
