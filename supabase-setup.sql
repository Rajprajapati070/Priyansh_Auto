create table if not exists public.site_content (
  id smallint primary key default 1 check (id = 1),
  content jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id text primary key,
  brand text not null,
  name text not null,
  price numeric,
  range_text text not null default '',
  featured boolean not null default false,
  image_url text not null default '',
  sort_order integer not null default 0,
  updated_at timestamptz not null default now()
);

grant select on public.site_content, public.products to anon, authenticated;
grant insert, update, delete on public.site_content, public.products to authenticated;

alter table public.site_content enable row level security;
alter table public.products enable row level security;

drop policy if exists "Public can read site content" on public.site_content;
create policy "Public can read site content"
  on public.site_content for select
  using (true);

drop policy if exists "Admins can manage site content" on public.site_content;
create policy "Admins can manage site content"
  on public.site_content for all
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Public can read products" on public.products;
create policy "Public can read products"
  on public.products for select
  using (true);

drop policy if exists "Admins can manage products" on public.products;
create policy "Admins can manage products"
  on public.products for all
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

insert into public.site_content (id, content)
values (
  1,
  '{
    "brandName": "PRIYANSH AUTO E.V. DEALERS",
    "heroLine1": "Switch to",
    "heroLine2": "electric.",
    "heroLine3": "Jaunpur’s E.V. dealer",
    "heroDescription": "Electric scooters from top brands — ask us about pricing, availability, test rides and finance options.",
    "locationHeading": "Fatehganj Bazar, Jaunpur",
    "address": "Fatehganj Bazar, Allahabad Road, Jaunpur, Uttar Pradesh, India",
    "phoneNumber": "918528889901",
    "whatsappNumber": "919321180132",
    "mapsUrl": "https://maps.app.goo.gl/KWpZro9vkLRYhnaA8?g_st=aw",
    "instagramUrl": "https://instagram.com/raj_boss_07ff",
    "instagramDisplay": "@raj_boss_07ff",
    "heroImage": "https://images.unsplash.com/photo-1648204798633-c51d248d637a?q=80&w=1400&auto=format&fit=crop",
    "enquiryImage": "https://images.unsplash.com/photo-1623079397242-c2e809a6ef1d?q=80&w=1200&auto=format&fit=crop",
    "contactImage": "https://images.unsplash.com/photo-1695834195972-9fd5877b8ad0?q=80&w=1200&auto=format&fit=crop"
  }'::jsonb
)
on conflict (id) do nothing;

insert into public.products (id, brand, name, price, range_text, featured, image_url, sort_order)
values
  ('p1', 'TVS', 'TVS iQube', 115000, 'Up to ~94–150 km (variant dependent)', true, 'https://static.prod-images.emergentagent.com/jobs/1c7be7ef-dbaf-4e6c-a3bb-a86f3c41538b/images/4df47238403e9126dc336a5b72b74547dc94b4fb797140730c4485aa66d955b9.jpeg', 1),
  ('p2', 'Bajaj', 'Bajaj Chetak', 114000, 'Up to ~153 km (variant dependent)', true, 'https://static.prod-images.emergentagent.com/jobs/1c7be7ef-dbaf-4e6c-a3bb-a86f3c41538b/images/341da8aa5a6345ff81d13d1dc0767af81f38171393c5bb03f4bb5459a5ec4f15.jpeg', 2),
  ('p3', 'Ather', 'Ather 450X', 151000, 'Up to ~161 km', true, 'https://static.prod-images.emergentagent.com/jobs/1c7be7ef-dbaf-4e6c-a3bb-a86f3c41538b/images/8f1e8bafe4503970c477d83c99d5d67c79d72a9a56ae706049c7d33b0c6146f3.jpeg', 3),
  ('p4', 'VIDA', 'VIDA VX2', 109000, 'Confirm with dealership', false, 'https://static.prod-images.emergentagent.com/jobs/1c7be7ef-dbaf-4e6c-a3bb-a86f3c41538b/images/1427eed0d567a6460b5cbf199b0a79cf7b62e79adefb33612d280b91eb5c1d91.jpeg', 4),
  ('p5', 'Honda', 'Honda Activa e', 117000, 'Up to ~102 km', false, 'https://static.prod-images.emergentagent.com/jobs/1c7be7ef-dbaf-4e6c-a3bb-a86f3c41538b/images/31516139b8fbfee5917c359082900ab6ee8d45e6e0509de33eb5529c8d452011.jpeg', 5),
  ('p6', 'Komaki', 'Komaki X One', null, 'Confirm with dealership', false, 'https://static.prod-images.emergentagent.com/jobs/1c7be7ef-dbaf-4e6c-a3bb-a86f3c41538b/images/ad023a77165ba28531d726fa4d460a25771a155eaceda457f52e372bc14bd4dd.jpeg', 6)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('site-images', 'site-images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Public can view site images" on storage.objects;
create policy "Public can view site images"
  on storage.objects for select
  using (bucket_id = 'site-images');

drop policy if exists "Admins can upload site images" on storage.objects;
create policy "Admins can upload site images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'site-images'
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
  );

drop policy if exists "Admins can update site images" on storage.objects;
create policy "Admins can update site images"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'site-images'
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
  )
  with check (
    bucket_id = 'site-images'
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
  );

drop policy if exists "Admins can delete site images" on storage.objects;
create policy "Admins can delete site images"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'site-images'
    and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
  );
