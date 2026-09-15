-- FETCH — PENDING. NOT A MIGRATION YET. DO NOT MOVE THIS FILE ON ITS OWN.
--
-- This is the fix for the SECURITY DEFINER click views. It lives in
-- supabase/pending/ rather than supabase/migrations/ so that `supabase db push`
-- will NOT pick it up, because applying it alone accomplishes nothing and
-- applying it late accomplishes nothing either.
--
-- WHEN IT RUNS: session 04, in the same pass that replaces the six
-- `pilot open` policies. Move it into supabase/migrations/ with a timestamp
-- AFTER the new policy migration, so that in a fresh rebuild the tightened
-- policies exist before the views start honouring them. Applying it before the
-- policies land is a no-op; applying it after them, in a separate later
-- session, means there is a window where the new policies are silently inert.
--
-- WHAT IT FIXES: click_counts, click_weeks and click_months are defined without
-- `security_invoker`, so they execute as the view owner and ignore row-level
-- security. Supabase's advisor flags all three at ERROR level. Right now this
-- bypasses nothing, because the policy on `clicks` is `using (true)`. The
-- moment session 04 scopes `clicks` to its owner, these views keep handing
-- every creator's tap data to any caller, straight past the new policy, with
-- no error and no warning.
--
-- VERIFY BY OBSERVING, NOT BY PARSING. After applying, in session 04:
--   set role anon;
--   select * from public.click_counts;   -- must respect the new clicks policy
--   reset role;
-- and re-run the security advisor; the three 0010_security_definer_view errors
-- must be gone. A migration that applied cleanly is not evidence it works —
-- that was the netlify.toml lesson from session 01.

begin;

alter view public.click_counts  set (security_invoker = true);
alter view public.click_weeks   set (security_invoker = true);
alter view public.click_months  set (security_invoker = true);

commit;
