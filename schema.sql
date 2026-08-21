-- ============================================================================
-- Dog-Friendly Spots UK & Ireland — Supabase schema
-- How to use: Supabase Dashboard -> SQL Editor -> New query -> paste -> Run
-- ============================================================================

-- 1) Create the listings table ------------------------------------------------
create table if not exists public.listings (
  id             bigint generated always as identity primary key,
  directory_slug text      not null default 'dog-friendly-uk',
  name           text      not null,
  category       text      not null check (category in ('pub', 'beach', 'trail')),
  region         text      not null,
  town           text,
  postcode       text,
  description    text,
  website        text,
  is_featured    boolean   not null default false, -- used later for paid featured listings
  created_at     timestamptz not null default now()
);

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
