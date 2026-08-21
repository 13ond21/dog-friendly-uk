# 🐾 Dog-Friendly Spots UK & Ireland

A free directory of **dog-friendly pubs, beaches, walking trails and dog parks** across
the UK and Ireland — with county-by-county coverage of England, Scotland, Wales,
Ireland and Northern Ireland (113 regions). A single static HTML page (no framework,
no build step) backed by a Supabase database, designed to be cloned and re-skinned for
future niche directory sites (wild swimming, mobile dog groomers, etc.).

## Project structure

| File | Purpose |
|---|---|
| `index.html` | The directory home page: SEO meta, filters, listing cards, AdSense placeholders, footer |
| `listing.html` | Per-listing detail pages (`listing.html?slug=…`) with their own title, meta and JSON-LD — so every one of the 1,766 places is individually indexable |
| `schema.sql` | Supabase table + indexes + Row Level Security — paste into the SQL editor |
| `dog-friendly-uk-listings.csv` | 2,172 starter listings (133 regions — every UK &amp; Irish county covered), ready for Supabase's CSV import |
| `sitemap.xml` | 1,767 URLs (homepage + every listing) — submit to Google Search Console |
| `robots.txt` / `og-image.png` | Crawling rules + social share image (1200×630) |
| `favicon.svg` | Paw-print favicon |
| `.gitignore` | Minimal ignore rules |

## How it works

- The site is hosted on **GitHub Pages** (static files only).
- The data lives in **Supabase** (free Postgres). The page fetches rows from the
  `listings` table where `directory_slug = 'dog-friendly-uk'` and renders them client-side.
- **Row Level Security** is enabled. Anonymous visitors can only `SELECT` — no one can
  insert, edit or delete from the public web. This is what makes exposing the anon key safe.
- The page also emits **schema.org structured data** (JSON-LD `WebSite` + `ItemList`) so
  search engines understand the listings, plus region quick-link chips for better crawling
  and navigation.
- Every listing card has **Google Maps** and **Apple Maps** buttons — they now drop an
  **exact pin** using each listing's GPS coordinates (all 1,766 places are geocoded), and
  fall back to an address search if coordinates are ever missing.
- The search box accepts **postcodes** (full or partial, UK & Irish, e.g. `LA23`, `SW1`,
  `BT7`, `D13`) and shows the dog-friendly spots in that area using a built-in
  postcode-area → region map.
- A **"Browse by category & region"** section links to pre-filtered views
  (e.g. "Dog-friendly beaches in Cornwall"), and every filter state is a **shareable
  URL** (`?category=beach&region=Cornwall`).
- Listings can be **sorted**: Recommended (featured first), **Most popular** (editorial
  popularity score), Name (A–Z), or **Closest to postcode** — which geocodes the postcode
  and ranks every listing by **real distance** using the stored GPS coordinates.
- Cards show **opening hours** where known (outdoor spaces are "open all year, dawn to
  dusk"), a **website** button, and — for toilet listings — **♿ accessible** and
  **🍼 baby change** flags where confirmed. A `phone` column is ready in the schema but
  is left blank rather than ship unverified numbers.
- There's a **Toilets** filter (curated starter list) plus a **"Toilets near me"** button
  in the header that returns live public-toilet results for the visitor's location via
  Google/Apple Maps.

---

## 1. Create a Supabase project (if you don't have one)

1. Go to <https://supabase.com> and sign up (GitHub or email).
2. Click **New project**.
3. Give it a name (e.g. `dog-friendly-uk`), set a database password, and pick a region
   close to your audience (e.g. `eu-west`).
4. Click **Create new project** and wait 1–2 minutes for it to provision.
5. When it's ready, click **Settings → API** (left sidebar) and copy two things:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon public** key (a long `eyJ...` JWT token)

> Already have a project? Just grab those two values from Settings → API. You don't need
> the `service_role` key for this site — and you should never put it in the front-end.

## 2. Run the schema

1. In the Supabase dashboard, open **SQL Editor → New query**.
2. Paste the entire contents of `schema.sql`.
3. Press **Run**. You should see "Success".
4. Confirm in the **Table Editor** sidebar that a `listings` table now exists.

The script does three things:

- creates the `listings` table (with a check constraint so category can only be
  `pub`, `beach`, `trail`, `dog_park` or `toilet`),
- adds indexes on `directory_slug`, `region` and `category`,
- **enables Row Level Security** and creates the **public read policy**:

```sql
alter table public.listings enable row level security;

create policy "Public read access for listings"
on public.listings for select
to anon
using (true);
```

To double-check it worked, run this in the SQL editor:

```sql
select relrowsecurity from pg_class where relname = 'listings'; -- expect: true
select policyname, cmd from pg_policies where tablename = 'listings';
```

## 3. Import the seed data

1. In the dashboard, open **Table Editor → listings**.
2. Click **Import data from CSV** (the button near the top right).
3. Upload `dog-friendly-uk-listings.csv`.
4. Confirm the columns map by header name (`directory_slug`, `name`, `category`, …).
5. Click **Import**. You should now see **2,172 rows** (16 columns).

The `id` and `created_at` columns are filled automatically; `is_featured` is `false`
for every row (flip it to `true` later when you sell featured listings).

Balance: **231 pubs · 609 dog parks · 623 trails · 447 beaches · 146 toilets ·
116 pet-friendly hotels &amp; accommodation**.
Every county of England, Wales, Scotland, Northern Ireland and Ireland is covered
(133 region values). Categories are `pub`, `beach`, `trail`, `dog_park`, `toilet`
and `accommodation`.

All listings use **county-level regions** (Antrim, Down, Dublin, Kerry, Galway, Gwynedd,
Pembrokeshire, Lothian, Highland, Surrey, Dorset, …) so the filters show real coverage —
113 regions in total. Categories are `pub`, `beach`, `trail`, `dog_park` and `toilet`
(a curated starter set of ~150 public toilets at parks, piers, visitor centres and
stations — the "Toilets near me" buttons in the header cover the whole UK live via
Google/Apple Maps).

> If you imported an earlier version of the CSV: **delete the existing rows first**
> (Table Editor → select rows → Delete), then import the new full CSV — otherwise you
> will get duplicate listings.

## 4. Add your Supabase keys to the site

Open `index.html` **and** `listing.html` and scroll to the `CONFIG` blocks (they must stay
in sync). Paste your **Project URL** and **anon public** key into the two constants in both files:

```js
const SUPABASE_URL = "https://abcdefgh.supabase.co";
const SUPABASE_ANON_KEY = "eyJ...";  // anon public key
```

Save. If the placeholders are still there, the page shows a friendly
"Database not connected yet" notice instead of a broken blank page.

## 5. Preview locally

From this folder, run:

```
python -m http.server 8000
```

Then open <http://localhost:8000> in your browser. (The site fetches straight from
Supabase, so no backend is needed locally.)

## 6. Deploy to GitHub Pages

**Status: done.** The repo was created, pushed and Pages enabled for this project:

```
https://github.com/13ond21/dog-friendly-uk   (repo)
https://13ond21.github.io/dog-friendly-uk/   (live site)
```

If you ever redeploy from scratch, the workflow is:

```
git init -b main
git add .
git commit -m "Initial commit: dog-friendly directory site"
git remote add origin https://github.com/13ond21/dog-friendly-uk.git
git push -u origin main
```

Then in the repo: **Settings → Pages → Build and deployment →
Source: "Deploy from a branch" → Branch: `main` → `/ (root)` → Save.**

## 7. Monetization (AdSense)

1. Apply at <https://adsense.google.com> once the site is live and has some content.
2. While waiting, submit the sitemap to Google Search Console:
   `https://search.google.com/search-console` → add your property → Sitemaps →
   submit `sitemap.xml`. It contains the homepage plus all **1,766 listing URLs** —
   each one is a real page (`listing.html?slug=…`) with its own title, meta
   description and schema.org `Place` structured data, so individual places can rank
   for searches like "Holkham Beach dog friendly".
3. When approved, follow the big `GOOGLE ADSENSE` comments inside `index.html`:
   paste the AdSense `<script>` tag into the `<head>`, then paste your ad unit's
   `<ins>` code into the `AD-SLOT-TOP` / `AD-SLOT-BOTTOM` divs in the body.
4. Replace `your@email.com` in the footer with your real address — the "Suggest a
   listing" link doubles as your outreach channel to businesses.

## 8. Clone for a new niche (wild swimming, dog groomers, …)

1. Copy this whole folder to a new folder.
2. In `index.html`, change the `DIRECTORY_SLUG` constant to a new value
   (e.g. `"wild-swimming"`).
3. Update the `<title>`, meta description, Open Graph tags and header/footer copy.
4. Update `schema.sql`'s default `directory_slug` and re-create the seed CSV with the
   new slug and your own places + original descriptions.
5. In Supabase, create a fresh project (or a new schema) and repeat steps 2–4 above.
6. Swap `favicon.svg`, delete this README's history, and push to a new GitHub repo.

That's the whole trick: the only thing that changes between niches is the slug, the
copy, and the seed data.

## Manual checklist (things only you can do)

- [x] Paste real Supabase keys into `index.html`
- [ ] Run `schema.sql` in the Supabase SQL Editor (creates the `listings` table + RLS)
- [ ] Import `dog-friendly-uk-listings.csv` via Table Editor (70 rows)
- [ ] Verify a handful of listings (pub dog policies and beach dog bans change)
- [x] Replace `YOUR-USERNAME` / `YOUR-REPO` in `index.html`, `robots.txt`, `sitemap.xml`
- [ ] Replace `your@email.com` in the footer
- [ ] Create a 1200×630 `og-image.png` and add it to the repo
- [x] Create the GitHub repo, push, and enable Pages (step 6)
- [ ] Apply for AdSense and paste the approved code (step 7)

