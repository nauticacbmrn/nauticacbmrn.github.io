-- ATUALIZAÇÃO V6 - IDENTIFICAÇÃO POR TIPO/PREFIXO + CHECKLIST OPERACIONAL
-- Execute uma vez no SQL Editor do Supabase.

alter table public.checklists
  add column if not exists condition text;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'checklists_condition_check'
  ) then
    alter table public.checklists
      add constraint checklists_condition_check
      check (condition is null or condition in ('fit','caution','unfit'));
  end if;
end $$;

-- Prefixo passa a ser a identificação única operacional.
-- Este índice ignora prefixos vazios de cadastros antigos.
create unique index if not exists vessels_prefix_unique_idx
on public.vessels (lower(prefix))
where prefix is not null and btrim(prefix) <> '';

-- O campo name é mantido internamente por compatibilidade com versões anteriores,
-- mas a V6 não o solicita nem o usa como identificação na interface.
