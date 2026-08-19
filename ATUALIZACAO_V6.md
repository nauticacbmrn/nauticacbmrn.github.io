# Náutica CBMRN — V6

Mudanças:
- Embarcação identificada por Tipo + Prefixo.
- Campo Nome removido da interface.
- Prefixo obrigatório na V6 e protegido contra duplicidade.
- Checklist usa OK / Alteração / N/A.
- Alterações possuem campo de descrição.
- Checklist recebe condição final: Apta, Ressalva ou Inapta.
- É possível gerar avarias automaticamente a partir das alterações.
- Checklist Inapta muda automaticamente a embarcação para Indisponível.

## PASSO OBRIGATÓRIO
Execute `supabase_update_v6.sql` uma vez no SQL Editor do Supabase.
Depois envie os arquivos desta versão para o repositório `nauticacbmrn.github.io`.
