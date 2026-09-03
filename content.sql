-- FETCH — content detail on tags
-- Run once in Supabase: SQL Editor → New query → paste → Run
-- Lets the dashboards show what the content actually was, not just that a link exists.

alter table tags add column if not exists content_format text;   -- Reel | Carousel | Story set | TikTok
alter table tags add column if not exists content_label  text;   -- short human descriptor, e.g. "storm season"
alter table tags add column if not exists posted_on      date;   -- when the creator published it
