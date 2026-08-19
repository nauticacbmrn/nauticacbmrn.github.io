-- ATUALIZAÇÃO V4 - HISTÓRICO E PERMISSÃO DE EXCLUSÃO
-- Execute uma vez no SQL Editor do Supabase.

drop policy if exists "audit_shared_delete" on public.audit_events;
create policy "audit_shared_delete"
on public.audit_events
for delete
to authenticated
using (public.is_active_member());

grant delete on public.audit_events to authenticated;
