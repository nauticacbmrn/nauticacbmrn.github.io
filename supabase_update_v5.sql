-- ATUALIZAÇÃO V5 - NÁUTICA CBMRN
-- Execute uma vez no SQL Editor do Supabase.

create table if not exists public.checklists (
  id uuid primary key default gen_random_uuid(),
  vessel_id uuid not null references public.vessels(id) on delete restrict,
  type text not null check (type in ('pre','post')),
  occurred_at timestamptz not null default now(),
  responsible text,
  items jsonb not null default '{}'::jsonb,
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.damages (
  id uuid primary key default gen_random_uuid(),
  vessel_id uuid not null references public.vessels(id) on delete restrict,
  reported_at timestamptz not null default now(),
  severity text not null default 'medium' check (severity in ('low','medium','high','critical')),
  responsible text,
  description text not null,
  status text not null default 'open' check (status in ('open','resolved')),
  resolved_at timestamptz,
  resolution_notes text,
  resolved_by uuid references auth.users(id),
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create index if not exists checklists_vessel_date_idx on public.checklists(vessel_id,occurred_at desc);
create index if not exists damages_vessel_status_idx on public.damages(vessel_id,status,reported_at desc);

alter table public.checklists enable row level security;
alter table public.damages enable row level security;

drop policy if exists "checklists_shared_read" on public.checklists;
create policy "checklists_shared_read" on public.checklists for select to authenticated using (public.is_active_member());
drop policy if exists "checklists_shared_insert" on public.checklists;
create policy "checklists_shared_insert" on public.checklists for insert to authenticated with check (public.is_active_member());

drop policy if exists "damages_shared_read" on public.damages;
create policy "damages_shared_read" on public.damages for select to authenticated using (public.is_active_member());
drop policy if exists "damages_shared_insert" on public.damages;
create policy "damages_shared_insert" on public.damages for insert to authenticated with check (public.is_active_member());
drop policy if exists "damages_shared_update" on public.damages;
create policy "damages_shared_update" on public.damages for update to authenticated using (public.is_active_member()) with check (public.is_active_member());

grant select, insert on public.checklists to authenticated;
grant select, insert, update on public.damages to authenticated;

do $$
begin
 if not exists (
   select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='checklists'
 ) then
   execute 'alter publication supabase_realtime add table public.checklists';
 end if;
 if not exists (
   select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='damages'
 ) then
   execute 'alter publication supabase_realtime add table public.damages';
 end if;
end $$;
