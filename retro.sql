-- Retroactive content: attach any number of existing posts to a tag
-- Run once in Supabase: SQL Editor → New query → paste → Run
create table if not exists tag_content (
  id uuid primary key default gen_random_uuid(),
  tag_id uuid references tags(id) on delete cascade,
  content_url text not null,
  created_at timestamptz default now()
);
alter table tag_content enable row level security;
create policy "pilot open" on tag_content for all using (true) with check (true);
