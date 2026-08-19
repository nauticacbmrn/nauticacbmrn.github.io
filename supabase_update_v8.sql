-- ATUALIZAÇÃO V8 - CHECKLIST EDITÁVEL E EXCLUÍVEL
-- Execute UMA VEZ no SQL Editor do Supabase.

drop policy if exists "checklists_shared_update" on public.checklists;
create policy "checklists_shared_update"
on public.checklists
for update
to authenticated
using (public.is_active_member())
with check (public.is_active_member());

drop policy if exists "checklists_shared_delete" on public.checklists;
create policy "checklists_shared_delete"
on public.checklists
for delete
to authenticated
using (public.is_active_member());

grant update, delete on public.checklists to authenticated;
