-- CONTROLE DE EMBARCAÇÕES CBMRN - SUPABASE
-- Execute este script uma vez no SQL Editor do projeto.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'operator' check (role in ('operator','admin')),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', new.email))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create table if not exists public.vessels (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text,
  prefix text,
  status text not null default 'available' check (status in ('available','inuse','maintenance','unavailable')),
  fuel numeric not null default 0,
  hours numeric not null default 0,
  next_maintenance date,
  base text,
  notes text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.vessel_logs (
  id uuid primary key default gen_random_uuid(),
  vessel_id uuid not null references public.vessels(id) on delete restrict,
  type text not null check (type in ('usage','fuel','cleaning','maintenance','damage','inspection')),
  occurred_at timestamptz not null default now(),
  responsible text,
  fuel_liters numeric not null default 0,
  fuel_value numeric not null default 0,
  hours numeric not null default 0,
  after_status text check (after_status is null or after_status in ('available','inuse','maintenance','unavailable')),
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.reservations (
  id uuid primary key default gen_random_uuid(),
  vessel_id uuid not null references public.vessels(id) on delete restrict,
  start_at timestamptz not null,
  end_at timestamptz not null,
  purpose text,
  responsible text,
  status text not null default 'scheduled' check (status in ('scheduled','completed','cancelled')),
  notes text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reservation_time_valid check (end_at > start_at)
);

create table if not exists public.audit_events (
  id bigint generated always as identity primary key,
  action text not null,
  entity_type text,
  entity_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create index if not exists vessel_logs_vessel_date_idx on public.vessel_logs(vessel_id, occurred_at desc);
create index if not exists reservations_vessel_time_idx on public.reservations(vessel_id, start_at, end_at);
create index if not exists audit_events_date_idx on public.audit_events(created_at desc);

alter table public.profiles enable row level security;
alter table public.vessels enable row level security;
alter table public.vessel_logs enable row level security;
alter table public.reservations enable row level security;
alter table public.audit_events enable row level security;

-- Todos os usuários autenticados e ativos compartilham a mesma frota.
create or replace function public.is_active_member()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.active = true
  );
$$;

drop policy if exists "profiles_read" on public.profiles;
create policy "profiles_read" on public.profiles for select to authenticated using (public.is_active_member());

drop policy if exists "profiles_self_update" on public.profiles;
create policy "profiles_self_update" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "vessels_shared_read" on public.vessels;
create policy "vessels_shared_read" on public.vessels for select to authenticated using (public.is_active_member());
drop policy if exists "vessels_shared_insert" on public.vessels;
create policy "vessels_shared_insert" on public.vessels for insert to authenticated with check (public.is_active_member());
drop policy if exists "vessels_shared_update" on public.vessels;
create policy "vessels_shared_update" on public.vessels for update to authenticated using (public.is_active_member()) with check (public.is_active_member());

drop policy if exists "logs_shared_read" on public.vessel_logs;
create policy "logs_shared_read" on public.vessel_logs for select to authenticated using (public.is_active_member());
drop policy if exists "logs_shared_insert" on public.vessel_logs;
create policy "logs_shared_insert" on public.vessel_logs for insert to authenticated with check (public.is_active_member());

drop policy if exists "reservations_shared_read" on public.reservations;
create policy "reservations_shared_read" on public.reservations for select to authenticated using (public.is_active_member());
drop policy if exists "reservations_shared_insert" on public.reservations;
create policy "reservations_shared_insert" on public.reservations for insert to authenticated with check (public.is_active_member());
drop policy if exists "reservations_shared_update" on public.reservations;
create policy "reservations_shared_update" on public.reservations for update to authenticated using (public.is_active_member()) with check (public.is_active_member());

drop policy if exists "audit_shared_read" on public.audit_events;
create policy "audit_shared_read" on public.audit_events for select to authenticated using (public.is_active_member());
drop policy if exists "audit_shared_insert" on public.audit_events;
create policy "audit_shared_insert" on public.audit_events for insert to authenticated with check (public.is_active_member());

grant select, update on public.profiles to authenticated;
grant select, insert, update on public.vessels to authenticated;
grant select, insert on public.vessel_logs to authenticated;
grant select, insert, update on public.reservations to authenticated;
grant select, insert on public.audit_events to authenticated;

-- Realtime: se uma tabela já estiver adicionada à publicação, ignore o erro daquela linha.
alter publication supabase_realtime add table public.vessels;
alter publication supabase_realtime add table public.vessel_logs;
alter publication supabase_realtime add table public.reservations;
alter publication supabase_realtime add table public.audit_events;

-- IMPORTANTE:
-- 1) Em Authentication, desative cadastro público (sign-ups) se o uso for interno.
-- 2) Crie os usuários manualmente no painel do Supabase.
-- 3) Depois de criar o primeiro usuário, você pode torná-lo admin:
-- update public.profiles set role='admin' where id='<UUID_DO_USUARIO>';
