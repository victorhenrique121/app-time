# Especificação do Projeto — Gestão de Time Society

## 1. Objetivo
Construir uma aplicação para administrar um único time amador de futebol Society/Fut7/Fut6. A primeira versão deve funcionar bem no navegador, com interface responsiva para celulares, tablets e computadores. A arquitetura deve permitir lançar versões Android e iOS futuramente, reutilizando o máximo possível do código Flutter.

O sistema centraliza:
- cadastro e situação dos jogadores;
- partidas e calendário;
- confirmação de presença, lista de espera e presença real;
- cobranças, pagamentos, despesas e saldo;
- histórico de partidas e movimentações;
- configurações básicas do time.

## 2. Princípios
1. Segurança e privacidade desde o início.
2. Código simples de navegar, compreender, testar e manter.
3. Interface consistente e responsiva.
4. Autorização aplicada no banco/servidor, não apenas escondendo botões.
5. Regras financeiras explícitas e auditáveis.
6. Evitar abstrações e dependências desnecessárias.
7. Não criar arquivos ou camadas só para seguir um padrão artificial.
8. Não afirmar que testes, análise estática ou build passaram sem executar os comandos e conferir a saída real.

## 3. Usuários e permissões

### 3.1 Administrador
Pode:
- configurar dados e identidade visual do time;
- convidar jogadores e administrar associações;
- criar, editar, cancelar e consultar partidas;
- definir limite de vagas, prazo de confirmação e regras da lista de espera;
- visualizar confirmações e registrar presença real;
- criar cobranças, registrar pagamentos e despesas;
- consultar relatórios e o resumo financeiro completo;
- corrigir registros financeiros com justificativa e trilha de auditoria.

### 3.2 Jogador
Pode:
- consultar informações gerais liberadas aos membros;
- visualizar partidas;
- confirmar ou cancelar a própria presença, conforme prazo e regras;
- consultar o próprio histórico de presença;
- visualizar suas próprias cobranças e pagamentos;
- editar apenas os dados pessoais explicitamente autorizados.

Não pode:
- consultar o financeiro geral;
- consultar dados privados de outros jogadores sem necessidade;
- alterar presenças, pagamentos, cobranças ou perfis de terceiros;
- promover a si mesmo a administrador;
- acessar dados de time ao qual não pertence;
- modificar seu papel ou suas permissões.

### 3.3 Acesso inicial e convites
- Não implementar cadastro público aberto por padrão.
- Documentar um processo seguro para criar o primeiro administrador.
- O administrador convida jogadores por um fluxo autenticado.
- Tokens de convite devem ser imprevisíveis, expirar e ser de uso único quando aplicável.
- Alterar parâmetros no navegador não pode permitir entrada em um time ou promoção de papel.
- Membros removidos/inativos devem perder acesso às informações protegidas.

## 4. Funcionalidades

### 4.1 Painel
Mostrar o próximo jogo, estado das confirmações, confirmados e vagas restantes. Para jogadores, mostrar cobranças pessoais pendentes. Para administradores, mostrar pendências e resumo financeiro. Não mostrar o financeiro global a jogadores.

### 4.2 Jogadores
- Listar membros ativos/inativos conforme permissões.
- Administrador pode convidar, editar, desativar e reativar membros.
- Coletar somente dados necessários.
- Não excluir silenciosamente histórico ligado a partidas ou finanças.
- Definir estados de membro e suas consequências de acesso.

### 4.3 Partidas
Cada partida pode conter data/hora, local, modalidade, observações, limite de jogadores, prazo de confirmação e estado (planejada, confirmada, concluída ou cancelada). Validar transições e impedir novas confirmações em partidas canceladas.

### 4.4 Presença e lista de espera
- Uma resposta por jogador por partida.
- Estados claros: confirmado, não vai, lista de espera ou sem resposta.
- Confirmação não equivale à presença real.
- Administrador pode registrar presença real.
- Ao atingir limite, aplicar lista de espera com ordem determinística.
- Operações concorrentes não podem ultrapassar o limite. Usar transações, restrições ou função segura no servidor/banco quando necessário.
- Definir comportamento para cancelamentos, promoções, alteração de limite e membros inativos.
- Não confiar em contagens calculadas apenas no cliente.

### 4.5 Financeiro
Separar cobranças, pagamentos recebidos, despesas pagas, valores pendentes e saldo de caixa.
- Permitir cobranças únicas; recorrência só se for implementada de forma confiável.
- Registrar valor, descrição, vencimento, jogador relacionado e estado quando aplicável.
- Registrar pagamentos com valor, data, método opcional e responsável pelo lançamento.
- Registrar despesas com valor, categoria, descrição, data e comprovante opcional.
- Corrigir/estornar com justificativa e auditoria; não apagar silenciosamente transações efetivadas.
- Usar `numeric`/`decimal` no banco ou inteiros em centavos; nunca ponto flutuante para dinheiro.
- Cobrança não paga não é dinheiro recebido.
- Impedir dupla contagem de pagamentos.
- Documentar pagamentos parciais, excedentes, estornos e cobranças canceladas.
- Jogadores só veem suas próprias cobranças e pagamentos; o livro-caixa é exclusivo do administrador.

### 4.6 Histórico e relatórios
- Histórico de partidas e presença real, quando registrada.
- Jogador consulta apenas seu próprio histórico individual.
- Administrador consulta relatórios básicos de cobranças, recebimentos, despesas e saldo.
- Totais calculados com regras consistentes e testadas.

### 4.7 Identidade visual e configurações
- Nome e escudo oficiais ainda dependem de definição do usuário.
- Não inventar identidade oficial. Usar identidade provisória configurável.
- Permitir alterar nome e escudo pelo administrador, se viável.
- Validar tamanho e tipo de arquivos enviados e proteger seu acesso.
- Usar tema, cores e componentes centralizados conforme `DESIGN_SYSTEM.md`.

### 4.8 Notificações
Começar com avisos dentro do aplicativo. E-mail, WhatsApp ou push são opcionais e exigem definição de provedor, custos e consentimento. Não afirmar que uma integração existe se não estiver configurada.

## 5. Requisitos não funcionais
- Priorizar uso em celular e adaptar para desktop.
- Interface em português brasileiro, com datas, horas e moeda formatadas para `pt-BR` e fuso horário documentado.
- Estados de carregamento, erro, vazio e sucesso nos fluxos principais.
- Validar dados no cliente e no servidor/banco.
- Tratar falhas de rede sem expor SQL, tokens ou detalhes internos.
- Versionar migrations SQL.
- Minimizar dados pessoais e restringir seu acesso.
- Garantir acessibilidade: navegação por teclado, foco visível, contraste e rótulos claros.

## 6. Stack técnica preferida
- Linguagem: Dart.
- UI multiplataforma: Flutter, começando por Flutter Web responsivo.
- Navegação: usar `go_router` se a complexidade de rotas justificar; não criar um sistema próprio.
- Backend gerenciado: Supabase Auth + PostgreSQL + RLS.
- Cliente: pacote oficial `supabase_flutter`.
- Arquivos: Supabase Storage com políticas de acesso, se uploads forem necessários.
- Hospedagem web sugerida: Firebase Hosting para os arquivos estáticos gerados pelo Flutter Web. Usar Firebase apenas como hospedagem, sem duplicar Auth ou banco; Supabase continua sendo backend. Se o repositório já tiver Vercel configurado, avaliar manter Vercel com build/deploy documentado antes de migrar.
- Versionamento: Git + GitHub.
- Testes: `flutter test`; testes de integração com `integration_test` para fluxos críticos.
- Qualidade: `dart format` e `flutter analyze`.
- Banco: migrations SQL versionadas.

Antes de adicionar qualquer dependência, explicar por que é necessária. Não criar backend paralelo sem justificativa. Operações privilegiadas devem ocorrer em função confiável de servidor ou função PostgreSQL cuidadosamente protegida. Nunca expor `service_role` no app.

## 7. Estrutura e legibilidade do código
Organizar por funcionalidade, mantendo uma estrutura inicial pequena. Exemplo indicativo:

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
  core/
    theme/
    widgets/
    utils/
  features/
    auth/
    dashboard/
    players/
    matches/
    finance/
    settings/
```

Essa árvore é uma orientação, não uma obrigação de criar todas as pastas e arquivos antecipadamente.
- Criar arquivos quando houver responsabilidade real que justifique separação.
- Evitar arquivos gigantes, mas também evitar um arquivo por método ou widget trivial.
- Manter UI, acesso a dados e regras de negócio separados quando a complexidade justificar.
- Preferir nomes claros e consistentes.
- Não introduzir Clean Architecture completa, múltiplas camadas de interfaces ou padrões sofisticados sem benefício concreto.
- Cada funcionalidade deve ser compreensível sem exigir navegar por muitas abstrações.
- Atualizar um pequeno guia de estrutura no README quando necessário.

## 8. Modelo de dados
Propor e revisar o modelo antes de criar migrations definitivas. Considerar entidades equivalentes a:
- `profiles`;
- `teams`;
- `team_members`;
- `matches`;
- `attendance`;
- `billing_charges`;
- `payments`;
- `financial_transactions` ou modelo equivalente;
- `audit_logs`.

A lista não obriga criar tabelas redundantes. Definir chaves, integridade referencial, restrições únicas, índices, timestamps, regras financeiras e RLS em todas as tabelas expostas à API. Impedir presença duplicada por jogador/partida.

## 9. Fora do escopo inicial
Não implementar sem decisão explícita:
- gestão complexa de múltiplos times;
- pagamentos reais via gateway;
- integração automática com WhatsApp;
- cadastro público irrestrito;
- estatísticas avançadas ou scouting;
- rede social pública;
- aplicativo nativo separado do Flutter;
- recursos que adicionem complexidade sem resolver uma necessidade atual.

## 10. Critérios de aceitação
O MVP só está pronto quando:
- autenticação, recuperação de acesso e convite estiverem documentados e funcionais;
- permissões forem impostas no banco e testadas;
- jogador não conseguir acessar financeiro global nem dados privados de terceiros;
- lista de espera respeitar limites mesmo sob concorrência;
- regras e cálculos financeiros estiverem documentados e testados;
- migrations puderem ser aplicadas conforme documentação;
- web funcionar em celular e desktop;
- `dart format`, `flutter analyze`, testes e build relevantes forem executados e resultados reais registrados;
- instalação, configuração, variáveis, implantação e recuperação estiverem documentadas;
- nenhum segredo tiver sido versionado.
