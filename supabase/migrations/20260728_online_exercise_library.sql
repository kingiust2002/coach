create table if not exists public.exercise_catalog (
  id text primary key,
  name_fa text not null,
  name_key text not null unique,
  name_en text not null default '',
  primary_muscle text not null,
  secondary_muscles jsonb not null default '[]'::jsonb,
  exercise_type text not null,
  equipment text not null,
  difficulty text not null,
  movement_pattern text not null,
  laterality text not null default 'bilateral',
  instructions text not null default '',
  safety_notes text not null default '',
  is_active boolean not null default true,
  is_published boolean not null default false,
  content_version integer not null default 1 check (content_version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.exercise_catalog_media (
  exercise_id text primary key references public.exercise_catalog(id) on delete cascade,
  video_object_key text not null,
  video_public_url text not null,
  poster_public_url text not null default '',
  secondary_image_public_url text not null default '',
  video_size_bytes bigint,
  duration_seconds integer,
  media_version integer not null default 1 check (media_version > 0),
  updated_at timestamptz not null default now()
);

create index if not exists exercise_catalog_public_filters_idx
  on public.exercise_catalog (
    is_published,
    is_active,
    primary_muscle,
    equipment,
    difficulty
  );

alter table public.exercise_catalog enable row level security;
alter table public.exercise_catalog_media enable row level security;

drop policy if exists "published exercises are publicly readable"
  on public.exercise_catalog;
create policy "published exercises are publicly readable"
  on public.exercise_catalog
  for select
  to anon, authenticated
  using (is_published and is_active);

drop policy if exists "published exercise media is publicly readable"
  on public.exercise_catalog_media;
create policy "published exercise media is publicly readable"
  on public.exercise_catalog_media
  for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.exercise_catalog exercise
      where exercise.id = exercise_catalog_media.exercise_id
        and exercise.is_published
        and exercise.is_active
    )
  );

comment on table public.exercise_catalog is
  'Published metadata for the versioned online exercise library.';
comment on table public.exercise_catalog_media is
  'Full-length video metadata. Binary objects are stored in Cloudflare R2.';
