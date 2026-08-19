# Controle de Embarcações CBMRN — V2 Online

Esta versão usa **Supabase** para que todos os aparelhos vejam o mesmo banco.

## 1. Criar o projeto Supabase

Crie um projeto no Supabase.

## 2. Criar as tabelas

Abra o **SQL Editor** do projeto, copie todo o conteúdo de `supabase_setup.sql` e execute.

Se alguma das quatro últimas linhas de `alter publication supabase_realtime add table ...` disser que a tabela já está na publicação, isso não é um problema. Ela já está habilitada para Realtime.

## 3. Segurança de usuários

Para uso interno, recomendamos **não permitir cadastro público**.

No painel do Supabase:
- Authentication → Providers / Sign Ups: desative cadastro público, conforme a interface atual do painel.
- Authentication → Users: crie manualmente uma conta para cada militar/guarnição que terá acesso.

O aplicativo não possui botão "Criar conta": somente login.

## 4. Conectar o aplicativo

No Supabase, copie:
- Project URL
- Publishable key (ou anon key, dependendo do painel)

Abra `config.js` e substitua:

COLE_AQUI_A_URL_DO_SUPABASE
COLE_AQUI_A_CHAVE_PUBLICAVEL_OU_ANON

**Nunca use a service_role key no aplicativo.**

## 5. Publicar

O projeto é estático e pode ser publicado em GitHub Pages, Netlify, Cloudflare Pages ou outro serviço HTTPS.

Arquivos que precisam ser publicados juntos:
- index.html
- config.js
- manifest.json
- service-worker.js

## Funcionamento compartilhado

Todos os usuários autenticados leem e atualizam:
- embarcações
- status
- combustível
- horímetro
- limpeza
- manutenção
- avarias
- inspeções
- reservas/agenda
- histórico de alterações

O Supabase Realtime avisa os aparelhos quando alguma dessas tabelas muda. O aplicativo recarrega os dados automaticamente.

## Auditoria

O app registra ações em `audit_events`, associadas ao UUID do usuário autenticado.

## Próxima evolução recomendada

Depois do teste operacional, vale adicionar:
- níveis de permissão (operador / supervisor / administrador);
- checklist pré e pós-uso;
- fotos de avarias usando Supabase Storage;
- assinatura/confirmação de entrega e recebimento;
- relatórios mensais de combustível e horímetro.
