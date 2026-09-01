-- Admin read access to waitlist signups
-- Run once in Supabase: SQL Editor → New query → paste → Run
create policy "pilot read" on waitlist for select using (true);
