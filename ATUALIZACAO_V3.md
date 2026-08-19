# Atualização V3

Mudanças:
- Exclusão definitiva apenas para embarcação sem registros nem reservas.
- Embarcações com histórico são arquivadas.
- Embarcações arquivadas podem ser restauradas em Mais.
- Tipos: Lancha, Moto Aquática, Bote inflável e Outra.
- Esqueci minha senha por e-mail.
- Botão Instalar aplicativo.

## PASSO OBRIGATÓRIO NO SUPABASE

Abra SQL Editor e execute apenas o arquivo:

supabase_update_v3.sql

Isso adiciona os campos de arquivamento e a permissão de exclusão segura.

## RECUPERAÇÃO DE SENHA

No Supabase:
Authentication → URL Configuration

Adicione a URL do seu GitHub Pages em:
Redirect URLs

Exemplo:
https://SEU-USUARIO.github.io/controle-embarcacoes/

Use exatamente a URL em que o aplicativo está publicado.

O link enviado por “Esqueci minha senha” voltará para essa URL e abrirá o formulário para criar uma nova senha.

## INSTALAÇÃO

Android/Chrome:
- O botão Instalar utiliza o prompt nativo quando disponível.

iPhone/iPad:
- O botão explica: Compartilhar → Adicionar à Tela de Início.
