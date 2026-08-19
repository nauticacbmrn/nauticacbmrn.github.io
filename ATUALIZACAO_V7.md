# Náutica CBMRN — V7

Correção da exclusão de embarcações.

A V6 verificava somente registros de uso e reservas antes de excluir. Com a inclusão de checklists e avarias, uma embarcação com checklist podia ser tratada como sem histórico, causando erro de chave estrangeira.

Na V7 a decisão é feita no próprio Supabase:

- sem uso, reserva, checklist ou avaria -> exclui definitivamente;
- com qualquer histórico -> arquiva;
- registra a ação no histórico.

## PASSO OBRIGATÓRIO
Execute `supabase_update_v7.sql` uma vez no SQL Editor do Supabase.
Depois atualize os arquivos do GitHub com a V7.
