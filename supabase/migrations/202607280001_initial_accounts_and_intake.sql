-- Coach cloud foundation v1
-- Accounts, public coach profiles, coach-athlete relationships and intake requests.

begin;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'athlete'
    check (role in ('coach', 'athlete', 'admin')),
  full_name text not null default '',
  phone text not null default '',
  avatar_url text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.coach_profiles (
  coach_id uuid primary key references public.profiles(id) on delete cascade,
  username text not null,
  display_name text not null default '',
  bio text not null default '',
  accepting_clients boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint coach_profiles_username_format
    check (username ~ '^[a-z0-9][a-z0-9_-]{2,29}$')
);

create unique index if not exists coach_profiles_username_lower_unique
  on public.coach_profiles (lower(username));

create table if not exists public.coach_athlete_memberships (
  id uuid primary key default gen_random_uuid(),
  coach_id uuid not null references public.profiles(id) on delete cascade,
  athlete_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'active'
    check (status in ('active', 'paused', 'ended')),
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint coach_athlete_distinct_users check (coach_id <> athlete_id),
  constraint coach_athlete_unique_pair unique (coach_id, athlete_id)
);

create table if not exists public.athlete_intake_requests (
  id uuid primary key default gen_random_uuid(),
  coach_id uuid not null references public.profiles(id) on delete cascade,
  applicant_user_id uuid references public.profiles(id) on delete set null,
  full_name text not null,
  phone text not null default '',
  birth_date date,
  primary_goal text not null default 'generalFitness'
    check (primary_goal in (
      'generalFitness', 'muscleGain', 'fatLoss', 'strength', 'endurance',
      'mobility', 'rehabilitation', 'sportPerformance', 'other'
    )),
  goal_details text not null default '',
  training_level text not null default 'beginner'
    check (training_level in ('beginner', 'intermediate', 'advanced')),
  experience_months integer not null default 0
    check (experience_months between 0 and 1200),
  preferred_days_per_week integer not null default 3
    check (preferred_days_per_week between 1 and 7),
  preferred_session_minutes integer not null default 60
    check (preferred_session_minutes between 10 and 360),
  training_environment text not null default 'gym'
    check (training_environment in ('gym', 'home', 'outdoor', 'mixed')),
  injuries text not null default '',
  medical_notes text not null default '',
  applicant_notes text not null default '',
  coach_notes text not null default '',
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'rejected', 'cancelled')),
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists athlete_intake_coach_status_idx
  on public.athlete_intake_requests (coach_id, status, submitted_at desc);

create index if not exists athlete_intake_applicant_idx
  on public.athlete_intake_requests (applicant_user_id, submitted_at desc);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  requested_role text;
begin
  requested_role := coalesce(new.raw_user_meta_data ->> 'role', 'athlete');
  if requested_role not in ('coach', 'athlete') then
    requested_role := 'athlete';
  end if;

  insert into public.profiles (id, role, full_name, phone)
  values (
    new.id,
    requested_role,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(new.raw_user_meta_data ->> 'phone', '')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists coach_profiles_set_updated_at on public.coach_profiles;
create trigger coach_profiles_set_updated_at
  before update on public.coach_profiles
  for each row execute function public.set_updated_at();

drop trigger if exists memberships_set_updated_at on public.coach_athlete_memberships;
create trigger memberships_set_updated_at
  before update on public.coach_athlete_memberships
  for each row execute function public.set_updated_at();

drop trigger if exists intake_requests_set_updated_at on public.athlete_intake_requests;
create trigger intake_requests_set_updated_at
  before update on public.athlete_intake_requests
  for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.coach_profiles enable row level security;
alter table public.coach_athlete_memberships enable row level security;
alter table public.athlete_intake_requests enable row level security;

revoke all on table public.profiles from anon;
revoke all on table public.coach_athlete_memberships from anon;
revoke all on table public.athlete_intake_requests from anon;

grant select on table public.coach_profiles to anon, authenticated;
grant select, insert, update on table public.profiles to authenticated;
grant insert, update, delete on table public.coach_profiles to authenticated;
grant select, insert, update, delete on table public.coach_athlete_memberships to authenticated;
grant select, insert, update on table public.athlete_intake_requests to authenticated;

drop policy if exists profiles_select_self on public.profiles;
create policy profiles_select_self
  on public.profiles for select
  to authenticated
  using (id = auth.uid());

drop policy if exists profiles_insert_self on public.profiles;
create policy profiles_insert_self
  on public.profiles for insert
  to authenticated
  with check (id = auth.uid());

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

drop policy if exists coach_profiles_public_read on public.coach_profiles;
create policy coach_profiles_public_read
  on public.coach_profiles for select
  to anon, authenticated
  using (true);

drop policy if exists coach_profiles_insert_self on public.coach_profiles;
create policy coach_profiles_insert_self
  on public.coach_profiles for insert
  to authenticated
  with check (
    coach_id = auth.uid()
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'coach'
    )
  );

drop policy if exists coach_profiles_update_self on public.coach_profiles;
create policy coach_profiles_update_self
  on public.coach_profiles for update
  to authenticated
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

drop policy if exists coach_profiles_delete_self on public.coach_profiles;
create policy coach_profiles_delete_self
  on public.coach_profiles for delete
  to authenticated
  using (coach_id = auth.uid());

drop policy if exists memberships_read_participants on public.coach_athlete_memberships;
create policy memberships_read_participants
  on public.coach_athlete_memberships for select
  to authenticated
  using (coach_id = auth.uid() or athlete_id = auth.uid());

drop policy if exists memberships_insert_by_coach on public.coach_athlete_memberships;
create policy memberships_insert_by_coach
  on public.coach_athlete_memberships for insert
  to authenticated
  with check (
    coach_id = auth.uid()
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'coach'
    )
  );

drop policy if exists memberships_update_by_coach on public.coach_athlete_memberships;
create policy memberships_update_by_coach
  on public.coach_athlete_memberships for update
  to authenticated
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

drop policy if exists memberships_delete_by_coach on public.coach_athlete_memberships;
create policy memberships_delete_by_coach
  on public.coach_athlete_memberships for delete
  to authenticated
  using (coach_id = auth.uid());

drop policy if exists intake_read_participants on public.athlete_intake_requests;
create policy intake_read_participants
  on public.athlete_intake_requests for select
  to authenticated
  using (coach_id = auth.uid() or applicant_user_id = auth.uid());

drop policy if exists intake_insert_self on public.athlete_intake_requests;
create policy intake_insert_self
  on public.athlete_intake_requests for insert
  to authenticated
  with check (
    applicant_user_id = auth.uid()
    and exists (
      select 1
      from public.coach_profiles cp
      where cp.coach_id = athlete_intake_requests.coach_id
        and cp.accepting_clients = true
    )
  );

drop policy if exists intake_update_by_coach on public.athlete_intake_requests;
create policy intake_update_by_coach
  on public.athlete_intake_requests for update
  to authenticated
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

commit;
