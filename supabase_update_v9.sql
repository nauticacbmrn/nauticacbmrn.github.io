-- ATUALIZAÇÃO V9 - EXCLUSÃO DEFINITIVA E EXCLUSÃO DE AVARIAS
-- Execute UMA VEZ no SQL Editor do Supabase.

-- Permitir excluir avarias individualmente
drop policy if exists "damages_shared_delete" on public.damages;
create policy "damages_shared_delete"
on public.damages
for delete
to authenticated
using (public.is_active_member());

grant delete on public.damages to authenticated;

-- Função segura para apagar uma embarcação ARQUIVADA e todo o histórico vinculado.
create or replace function public.purge_archived_vessel(p_vessel_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_archived boolean;
  v_label text;
begin
  if not public.is_active_member() then
    raise exception 'Usuário sem permissão.';
  end if;

  select archived,
         coalesce(type,'Embarcação') ||
         case when prefix is not null and btrim(prefix) <> '' then ' — ' || prefix else '' end
    into v_archived, v_label
  from public.vessels
  where id = p_vessel_id;

  if v_label is null then
    raise exception 'Embarcação não encontrada.';
  end if;

  if coalesce(v_archived,false) = false then
    raise exception 'A embarcação precisa estar arquivada antes da exclusão definitiva.';
  end if;

  -- Registrar antes de apagar
  insert into public.audit_events(action,entity_type,entity_id,details,created_by)
  values(
    'Embarcação e histórico excluídos definitivamente',
    'vessel',
    p_vessel_id,
    jsonb_build_object('label',v_label),
    auth.uid()
  );

  delete from public.checklists where vessel_id = p_vessel_id;
  delete from public.damages where vessel_id = p_vessel_id;
  delete from public.reservations where vessel_id = p_vessel_id;
  delete from public.vessel_logs where vessel_id = p_vessel_id;
  delete from public.vessels where id = p_vessel_id;
end;
$$;

revoke all on function public.purge_archived_vessel(uuid) from public;
grant execute on function public.purge_archived_vessel(uuid) to authenticated;
