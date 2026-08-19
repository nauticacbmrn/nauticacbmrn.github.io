-- ATUALIZAÇÃO V3 - CONTROLE DE EMBARCAÇÕES CBMRN
-- Execute este arquivo uma vez no SQL Editor do mesmo projeto Supabase.

alter table public.vessels
  add column if not exists archived boolean not null default false;

alter table public.vessels
  add column if not exists archived_at timestamptz;

-- A V3 exclui definitivamente somente embarcações sem histórico.
-- Para isso, usuários autenticados e ativos precisam de permissão DELETE em vessels.
drop policy if exists "vessels_shared_delete" on public.vessels;
create policy "vessels_shared_delete"
on public.vessels
for delete
to authenticated
using (public.is_active_member());

grant delete on public.vessels to authenticated;
