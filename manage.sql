-- Inbox management: track handled waitlist requests
-- Run once in Supabase: SQL Editor → New query → paste → Run
alter table waitlist add column if not exists status text not null default 'new';
create policy "pilot update" on waitlist for update using (true) with check (true);
