# Tag & Prove — Setup

Three steps, about ten minutes.

## 1. Create the database
1. Go to supabase.com, sign in, create a new project (free tier). Name it fetch-pilot.
2. In the left menu, open SQL Editor → New query.
3. Paste everything from schema.sql and hit Run. You should see "Success."

## 2. Get your two keys
1. In Supabase, open Project Settings → API.
2. Copy the Project URL (looks like https://xxxx.supabase.co).
3. Copy the anon public key (the long one starting with eyJ). This key is safe to use in the app.

## 3. Put the app online
Easiest path — Netlify, no account setup gymnastics:
1. Go to app.netlify.com, sign in.
2. Drag the index.html file onto the "Deploy" drop zone. Done — you get a live URL.

Or Vercel:
1. Go to vercel.com, New Project, and upload/import the file.

Then open your live URL, go to the Setup tab, paste the Project URL and anon key, and hit Connect. The badge at the top switches from "Demo mode" to "Connected — data is saved."

## What it does
- **Check a video** — paste a Reel or TikTok link. Network match shows the tracked link and code; no match saves a lead. Your recruitment list builds itself.
- **Create a tag** — pair a creator with a property. Generates the promo code and tracked link.
- **Log a booking** — enter a reported code and value. The 5/5 split calculates instantly.
- **Proof** — the running table: bookings, GMV, creator earnings, FETCH earnings. CSV export for sharing.
- **Network** — add pilot properties and tour operators.

## Two honest notes
- Access is pilot-grade: anyone with the app URL can read and write. Fine for you and a handful of trusted pilot partners. Real logins come with the months 3-9 build.
- Instagram Reel links don't reveal who posted them, so "Check a video" can't always identify the creator on IG. TikTok links work fully. For IG, create the tag directly — you'll know the creator anyway during the pilot.
