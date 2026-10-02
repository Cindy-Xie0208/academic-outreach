-- Academic Outreach private workspace
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','mentor')),
  display_name text,
  bio text,
  avatar_url text,
  created_at timestamptz default now()
);

create table if not exists public.mentor_access (
  owner_id uuid not null references auth.users(id) on delete cascade,
  mentor_id uuid not null references auth.users(id) on delete cascade,
  primary key (owner_id, mentor_id)
);

create table if not exists public.professors (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  university text,
  research_areas text,
  homepage text,
  status text default 'Preparing',
  notes text,
  updated_at timestamptz default now(),
  created_at timestamptz default now()
);

create table if not exists public.outreach_emails (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  professor_id uuid references public.professors(id) on delete set null,
  subject text,
  body text,
  status text default 'Draft',
  updated_at timestamptz default now(),
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;
alter table public.mentor_access enable row level security;
alter table public.professors enable row level security;
alter table public.outreach_emails enable row level security;

-- profiles: each user can read/update their own profile
create policy "profiles self read" on public.profiles for select using (id = auth.uid());
create policy "profiles self update" on public.profiles for update using (id = auth.uid());

-- mentor_access: owner can manage own mentor links; mentor can see links involving them
create policy "owner manages mentor access" on public.mentor_access
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "mentor sees own access" on public.mentor_access
for select using (mentor_id = auth.uid());

-- professors: owner full access
create policy "owner full professors" on public.professors
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

-- mentors can only read owner records explicitly shared with them
create policy "mentor read professors" on public.professors
for select using (
  exists (
    select 1 from public.mentor_access ma
    where ma.owner_id = professors.owner_id
      and ma.mentor_id = auth.uid()
  )
);

-- outreach emails: owner full access
create policy "owner full emails" on public.outreach_emails
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

-- mentors can only read shared owner's emails
create policy "mentor read emails" on public.outreach_emails
for select using (
  exists (
    select 1 from public.mentor_access ma
    where ma.owner_id = outreach_emails.owner_id
      and ma.mentor_id = auth.uid()
  )
);

-- IMPORTANT:
-- Create both users in Supabase Auth first.
-- Then insert their profile rows and link them, replacing UUIDs below:
--
-- insert into public.profiles (id, role, display_name)
-- values
-- ('OWNER_USER_UUID','owner','Cindy'),
-- ('MENTOR_USER_UUID','mentor','Application Mentor');
--
-- insert into public.mentor_access (owner_id, mentor_id)
-- values ('OWNER_USER_UUID','MENTOR_USER_UUID');
