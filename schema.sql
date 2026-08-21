-- ============================================================================
-- Dog-Friendly Spots UK & Ireland — Supabase schema
-- How to use: Supabase Dashboard -> SQL Editor -> New query -> paste -> Run
-- ============================================================================

-- 1) Create the listings table ------------------------------------------------
create table if not exists public.listings (
  id             bigint generated always as identity primary key,
  directory_slug text      not null default 'dog-friendly-uk',
  name           text      not null,
  category       text      not null check (category in ('pub', 'beach', 'trail', 'dog_park', 'toilet', 'accommodation', 'restaurant')),
  region         text      not null,
  town           text,
  postcode       text,
  description    text,
  website        text,
  is_featured    boolean   not null default false, -- used later for paid featured listings
  opening_hours  text,                              -- e.g. "Open all year (outdoor space, dawn to dusk)"
  phone          text,
  popularity     integer   not null default 3,      -- editorial 1-5 for "Most popular" sorting
  wheelchair_accessible boolean,                    -- toilets: where confirmed
  baby_change    boolean,                           -- toilets: where confirmed
  seasonal_rules text,                              -- beaches: seasonal dog bans, e.g. "Dogs excluded from the main beach, 1 May – 30 September"
  latitude       double precision,                  -- approx. coords from public geocoding (area level)
  longitude      double precision,
  created_at     timestamptz not null default now()
);

-- 1b) Allow existing databases to accept the new dog_park category ------------
-- (Fresh installs get dog_park via the inline check above; these lines make the
--  script safe to re-run on a database that was created before dog parks existed.)
alter table public.listings drop constraint if exists listings_category_check;
alter table public.listings add constraint listings_category_check
  check (category in ('pub', 'beach', 'trail', 'dog_park', 'toilet', 'accommodation', 'restaurant'));

-- 1c) Columns added in later versions of the schema (safe to run on older DBs) --
alter table public.listings add column if not exists opening_hours text;
alter table public.listings add column if not exists phone text;
alter table public.listings add column if not exists popularity integer not null default 3;
alter table public.listings add column if not exists wheelchair_accessible boolean;
alter table public.listings add column if not exists baby_change boolean;
alter table public.listings add column if not exists seasonal_rules text;
alter table public.listings add column if not exists latitude double precision;
alter table public.listings add column if not exists longitude double precision;

-- 2) Indexes for fast filtering -----------------------------------------------
create index if not exists listings_directory_slug_idx on public.listings (directory_slug);
create index if not exists listings_region_idx        on public.listings (region);
create index if not exists listings_category_idx      on public.listings (category);

-- 3) Row Level Security --------------------------------------------------------
-- Tables in Supabase are closed by default. This enables RLS and opens
-- READ-ONLY access for anonymous visitors — exactly what the public site needs.
-- No other operations (insert/update/delete) are allowed anonymously.
alter table public.listings enable row level security;

drop policy if exists "Public read access for listings" on public.listings;
create policy "Public read access for listings"
on public.listings
for select
to anon
using (true);

-- 3b) GRANT read access to the anon / authenticated roles ---------------------
-- IMPORTANT: tables created via the SQL Editor (raw SQL) are NOT auto-granted
-- to Supabase's built-in roles. Without these GRANTs the public site gets
-- "permission denied for table listings" even with RLS enabled.
grant select on table public.listings to anon;
grant select on table public.listings to authenticated;

-- 4) Verify everything is correct ----------------------------------------------
-- SELECT relrowsecurity FROM pg_class WHERE relname = 'listings';   -- expect: true
-- SELECT policyname, cmd, permissive FROM pg_policies WHERE tablename = 'listings';
-- SELECT * FROM public.listings LIMIT 5;
-- ============================================================================
