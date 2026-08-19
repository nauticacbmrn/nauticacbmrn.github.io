-- ATUALIZAÇÃO V7 - EXCLUSÃO/ARQUIVAMENTO SEGURO
-- Execute UMA VEZ no SQL Editor do Supabase.

create or replace function public.remove_or_archive_vessel(p_vessel_id uuid)
returns table(action text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_has_history boolean;
  v_label text;
begin
  if not public.is_active_member() then
    raise exception 'Usuário sem permissão.';
  end if;

  select coalesce(type,'Embarcação') ||
         case when prefix is not null and btrim(prefix) <> '' then ' — ' || prefix else '' end
    into v_label
  from public.vessels
  where id = p_vessel_id;

  if v_label is null then
    raise exception 'Embarcação não encontrada.';
  end if;

  select
    exists(select 1 from public.vessel_logs where vessel_id = p_vessel_id)
    or exists(select 1 from public.reservations where vessel_id = p_vessel_id)
    or exists(select 1 from public.checklists where vessel_id = p_vessel_id)
    or exists(select 1 from public.damages where vessel_id = p_vessel_id)
  into v_has_history;

  if v_has_history then
    update public.vessels
       set archived = true,
           archived_at = now(),
           updated_by = auth.uid(),
           updated_at = now()
     where id = p_vessel_id;

    insert into public.audit_events(action, entity_type, entity_id, details, created_by)
    values (
      'Embarcação arquivada',
      'vessel',
      p_vessel_id,
      jsonb_build_object('label',v_label,'reason','historico_existente'),
      auth.uid()
    );

    return query select 'archived'::text;
  else
    insert into public.audit_events(action, entity_type, entity_id, details, created_by)
    values (
      'Embarcação excluída definitivamente',
      'vessel',
      p_vessel_id,
      jsonb_build_object('label',v_label,'reason','sem_historico'),
      auth.uid()
    );

    delete from public.vessels where id = p_vessel_id;

    return query select 'deleted'::text;
  end if;
end;
$$;

revoke all on function public.remove_or_archive_vessel(uuid) from public;
grant execute on function public.remove_or_archive_vessel(uuid) to authenticated;
