# Banco de dados e Supabase

## Escopo

O schema foi preparado para múltiplas equipes, mesmo que o produto comece com
um único time. Cada dado de operação pertence a `team_id`; a associação ativa
e o papel são consultados no banco. Não há cadastro público aberto na
configuração local.

As migrations criam somente objetos novos e não apagam tabelas, dados ou
histórico. Se um projeto remoto já tiver tabelas com os mesmos nomes, pare e
revise o conflito antes de aplicar a migration.

## Modelo e relacionamentos

| Tabela | Finalidade e relacionamentos |
| --- | --- |
| `teams` | Configurações do time, fuso horário e caminho opcional do escudo. |
| `profiles` | Nome de exibição mínimo, ligado 1:1 a `auth.users`. |
| `team_members` | Associação por equipe e usuário, com papel (`admin`/`player`) e situação (`invited`/`active`/`inactive`). |
| `players` | Dados esportivos mínimos da associação, por enquanto a posição preferida. |
| `matches` | Calendário, modalidade, limite, prazo e situação da partida. |
| `match_responses` | Uma resposta por membro e partida; registra estado, ordem da fila e presença real. |
| `charges` | Cobrança vinculada ao jogador; valores exatos em `numeric(12,2)`. |
| `payments` | Recebimentos parciais vinculados a cobranças, com idempotência e estorno. |
| `expenses` | Despesas do time com valor exato, responsável e estorno. |
| `financial_audit` | Trilha append-only de pagamentos registrados, cancelamentos e estornos. |

As chaves estrangeiras compostas impedem associar uma resposta, cobrança ou
pagamento a dados de outra equipe. Registros históricos não são apagados pela
API. Datas são `timestamptz` em UTC; a equipe guarda o nome do fuso para
formatação na interface.

### Regras para presença e lista de espera

- Uma ausência de resposta é representada pela ausência de linha.
- `respond_to_match` aceita somente `confirmed` ou `not_going`; a fila é
  calculada no banco e não pode ser escrita diretamente pelo cliente.
- A função bloqueia a linha da partida durante a operação, atribui ordem
  crescente e promove o próximo membro ativo após uma desistência.
- Confirmações existentes não são removidas automaticamente ao reduzir a
  capacidade. A política de redução precisa ser definida antes de a UI de
  administração permitir essa alteração.
- A inativação de membro revoga imediatamente o acesso aos dados. A gestão
  completa dessa transição e a promoção automática da fila serão integradas
  com o fluxo de administração nas fases correspondentes.

### Regras financeiras

- Cobranças podem receber pagamentos parciais, mas o total efetivamente
  recebido não pode ultrapassar o valor devido.
- `record_charge_payment` serializa lançamentos por cobrança e recebe uma
  chave de idempotência para que uma repetição de requisição não duplique o
  pagamento.
- O estado pago/parcial/pendente é derivado dos pagamentos postados; não é
  duplicado em uma coluna editável da cobrança.
- Um pagamento postado não é apagado. O administrador deve estorná-lo com
  justificativa antes de cancelar uma cobrança.
- Despesas também são preservadas e estornadas com justificativa.
- `financial_audit` guarda ator, ação, registro, horário e justificativa de
  correções; não armazena payloads pessoais desnecessários.

## Autorização e RLS

RLS está habilitada em todas as tabelas da aplicação no schema `public`.
Permissões de tabela/coluna e políticas são usadas em conjunto. O schema
`app_private` não é exposto pela API. As funções auxiliares `SECURITY DEFINER`
usam `search_path` vazio, qualificam objetos e derivam o usuário de
`auth.uid()`.

| Recurso | Jogador ativo | Administrador ativo |
| --- | --- | --- |
| Time e partidas | Lê apenas o próprio time e suas partidas. | Lê e atualiza o próprio time; cria e edita partidas. |
| Perfil e jogador | Lê/edita o próprio perfil permitido; lê nomes compartilhados do mesmo time. | Lê jogadores do próprio time e gerencia a posição preferida. |
| Associação | Lê a própria associação e membros ativos do mesmo time; não altera papel. | Lê e atualiza associações do próprio time e pode associar usuários já existentes no Supabase. O envio de convites será integrado na Fase 3. |
| Presença | Lê a própria resposta e altera-a apenas por `respond_to_match`. | Lê todas as respostas e pode registrar presença real. |
| Financeiro | Lê somente suas cobranças e pagamentos. | Lê o financeiro do próprio time; cria cobranças e despesas; registra e estorna via funções restritas. |
| Auditoria | Sem acesso. | Lê eventos financeiros do próprio time. |

Usuários anônimos não recebem privilégios nas tabelas. Não há políticas de
`DELETE`; associações e registros financeiros não são removidos pela API.
Funções privilegiadas estão restritas a `authenticated` e conferem novamente
associação ativa e papel no banco.

## Configuração local

Requisitos: Flutter/Dart, Node.js para invocar o CLI e Docker Desktop em
execução. O ambiente inspecionado tem Flutter e Node.js, mas não tem Docker ou
`psql`. A migration e os 34 assertions foram executados em PostgreSQL WASM
temporário com stubs para `auth.uid()` e pgTAP; isso valida SQL e regras no
engine PostgreSQL, mas não substitui a execução no Supabase local. A tentativa
de iniciar o Supabase CLI foi bloqueada pela ausência de Docker/Podman.

1. Instale/inicie o Docker Desktop.
2. Execute `npx supabase@latest start` na raiz do projeto. O CLI prepara o
   Supabase local a partir de `supabase/config.toml`.
3. Execute `npx supabase@latest test db` para aplicar migrations e rodar os
   testes pgTAP.
4. Para recriar o banco local do zero, use
   `npx supabase@latest db reset`. **Esse comando apaga os dados locais**; não
   o use em um banco remoto.

A migration inicial está em
[`migrations/20261011170000_initial_schema.sql`](migrations/20261011170000_initial_schema.sql)
e os testes em [`tests/database/security.test.sql`](tests/database/security.test.sql).

## Conectar um projeto Supabase remoto

1. Crie um projeto Supabase no Dashboard e guarde URL, referência do projeto e
   senha do banco em um gerenciador de segredos.
2. Mantenha o cadastro público desabilitado em Authentication. A opção
   `enable_signup = false` em `config.toml` configura o Supabase local; não
   altera automaticamente um projeto remoto existente.
3. Use uma chave publishable (`sb_publishable_...`) no cliente. A chave
   legada `anon` continua funcionando como compatibilidade, mas está sendo
   descontinuada pelo Supabase. Ambas são públicas e dependem de RLS; não
   substituem autorização.
4. Configure `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` no ambiente de build
   do Flutter. `AppConfig` aceita `SUPABASE_ANON_KEY` apenas como fallback
   legado. Para desenvolvimento, use `--dart-define`; `.env.example` contém
   somente placeholders e não é carregado automaticamente.
5. Nunca use `service_role`, `sb_secret_...` ou senha de banco no Flutter,
   Flutter Web, Git ou logs. Essas credenciais pertencem somente a ambientes
   confiáveis de administração/servidor.
6. Instale/autentique o CLI e vincule explicitamente o projeto:

   ```powershell
   npx supabase@latest login
   npx supabase@latest link --project-ref <referencia-do-projeto>
   npx supabase@latest db push --dry-run
   ```

7. Revise o plano, o alvo e o estado do banco no Dashboard antes de aplicar
   `npx supabase@latest db push`. Nenhum comando remoto foi executado nesta
   tarefa. Faça backup e confirme autorização antes de qualquer aplicação.

## Primeiro administrador

O primeiro administrador é criado manualmente por uma pessoa confiável no
Dashboard/SQL Editor, depois de criar o usuário por um fluxo administrativo do
Supabase. Não habilite signup público para contornar essa etapa. Execute o
bloco abaixo uma única vez no projeto correto, substituindo o UUID pelo `id`
do usuário em Authentication > Users e o nome pelo nome aprovado do time:

```sql
begin;

do $$
declare
  v_user_id uuid := 'SUBSTITUA-PELO-UUID-DO-USUARIO'::uuid;
  v_team_id uuid;
begin
  if not exists (select 1 from auth.users where id = v_user_id) then
    raise exception 'O usuário informado não existe em auth.users';
  end if;

  insert into public.profiles (id, display_name)
  values (v_user_id, 'NOME DO ADMINISTRADOR')
  on conflict (id) do nothing;

  insert into public.teams (name, created_by)
  values ('NOME APROVADO DO TIME', v_user_id)
  returning id into v_team_id;

  insert into public.team_members (
    team_id, user_id, role, status, created_by, joined_at
  )
  values (v_team_id, v_user_id, 'admin', 'active', v_user_id, now());
end;
$$;

commit;
```

Guarde o UUID do time e mantenha registro da pessoa que executou o bootstrap.
O script cria um novo time e não é idempotente; não o execute novamente para
um time já criado. Usuários seguintes devem entrar por convites autenticados,
implementados na Fase 3.

## Limites e pendências desta fase

- O banco remoto não foi conectado nem validado.
- O ambiente sem Docker impediu executar `supabase test db` contra a stack
  oficial local. Os 34 assertions passaram no PostgreSQL WASM temporário;
  repita-os via Supabase CLI antes de aplicar qualquer migration remotamente.
- O Flutter ainda não inicializa `supabase_flutter`; essa integração e o fluxo
  de autenticação pertencem à Fase 3.
- A gestão de convites, transições de membro e regras para reduzir capacidade
  precisa ser ligada às funções e fluxos correspondentes antes de expor essas
  operações na interface.

## Documentação oficial consultada

- [Supabase: Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase: proteção da Data API com grants e RLS](https://supabase.com/docs/guides/api/securing-your-api)
- [Supabase: migrations locais](https://supabase.com/docs/guides/local-development/database-migrations)
- [Supabase: testes de banco com pgTAP](https://supabase.com/docs/guides/database/testing)
- [Supabase: chaves de API](https://supabase.com/docs/guides/api/api-keys)
