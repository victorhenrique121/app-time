# Plano de Implementação — Gestão de Time Society

## Regras de execução
Trabalhar em fases pequenas e verificáveis. Inspecionar repositório e Git antes de editar; preservar mudanças existentes. Não substituir arquivos inteiros sem necessidade. Não afirmar que comandos passaram sem executar e conferir a saída.

## Fase 0 — Inspeção e planejamento
- Ler `AGENTS.md`, `PROJECT_SPEC.md`, `DESIGN_SYSTEM.md` e `SECURITY.md`.
- Inspecionar estrutura, estado Git, arquivos, dependências e ferramentas instaladas.
- Verificar se Flutter SDK/Dart estão disponíveis e documentar comandos necessários.
- Identificar funcionalidades existentes, lacunas, riscos e decisões pendentes.
- Apresentar plano antes de mudanças extensas.
**Saída:** diagnóstico, arquitetura proposta, riscos e perguntas bloqueantes.

## Fase 1 — Base Flutter
- Criar/configurar projeto Flutter com suporte web.
- Configurar formatação, análise estática e estrutura modular enxuta.
- Criar tema visual, navegação e componentes-base realmente necessários.
- Criar configuração segura de ambiente e `.env.example` sem segredos.
- Configurar páginas de carregamento, erro e acesso negado.
- Adicionar testes iniciais.
**Verificações:** `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test` e `flutter build web`, conforme aplicável.

## Fase 2 — Banco, migrations e segurança
- Desenhar e justificar o modelo de dados.
- Criar migrations SQL versionadas.
- Definir constraints, índices, chaves estrangeiras e RLS.
- Criar políticas para anônimo, jogador, membro inativo e administrador.
- Documentar primeiro administrador e convites.
- Criar testes de autorização contra ambiente de desenvolvimento/teste.
**Critério:** políticas e estrutura documentadas e testes executáveis.

## Fase 3 — Autenticação e associação
- Integrar Supabase com `supabase_flutter`.
- Implementar login, logout, recuperação de acesso e convites.
- Buscar papel/associação de fonte confiável.
- Implementar tratamento de sessão expirada e membro inativo.
- Proteger rotas para UX, mantendo a segurança real no banco.
**Critério:** fluxos funcionais e sem cadastro público indevido.

## Fase 4 — Time e jogadores
- Implementar listagem e gerenciamento administrativo.
- Implementar perfil próprio e edição de campos autorizados.
- Restringir dados pessoais por papel.
- Testar tentativas de editar terceiros.
**Critério:** operações obedecem às políticas e regras documentadas.

## Fase 5 — Partidas e presença
- Implementar criação, edição e cancelamento de partidas.
- Implementar confirmação/cancelamento da própria presença.
- Implementar limite, lista de espera e promoção.
- Implementar registro de presença real.
- Proteger concorrência e cobrir regras com testes.
**Critério:** limites e ordem da lista respeitados mesmo sob concorrência.

## Fase 6 — Financeiro
- Implementar cobranças, pagamentos, despesas e resumo.
- Documentar pagamento parcial, estorno, cancelamento e vencimento.
- Usar valores exatos e impedir dupla contagem.
- Implementar auditoria para correções relevantes.
- Testar cálculos e permissões.
**Critério:** testes de regras financeiras e acesso aprovados.

## Fase 7 — Histórico, relatórios e configurações
- Implementar histórico e relatórios essenciais.
- Configurar nome e escudo do time.
- Implementar uploads com políticas seguras, se necessários.
**Critério:** relatórios consistentes e sem vazamento para jogadores.

## Fase 8 — Interface e acessibilidade
- Revisar web em celular, tablet e desktop.
- Revisar teclado, foco, contraste, rótulos e mensagens.
- Verificar estados vazios, carregamento, erro e sucesso.
- Evitar abstrações e arquivos desnecessários.
**Critério:** fluxos principais utilizáveis em diferentes tamanhos de tela.

## Fase 9 — Qualidade e segurança
- Executar `dart format`, `flutter analyze`, `flutter test` e build web.
- Executar testes de integração e autorização quando viável.
- Revisar dependências, segredos, logs e mensagens de erro.
- Registrar comandos, resultados reais e falhas restantes.
**Critério:** nenhum bloqueador conhecido omitido no relatório.

## Fase 10 — Publicação e documentação
- Documentar Supabase, variáveis de ambiente, migrations e criação segura do primeiro administrador.
- Configurar hospedagem web. Preferir Firebase Hosting para build estático Flutter Web, salvo configuração existente adequada no Vercel.
- Documentar preview/teste antes de produção.
- Documentar backups, recuperação e limitações.
- Preparar orientações para futuras builds Android/iOS, sem implementar as lojas antes da hora.
**Critério:** outra pessoa consegue configurar e executar o projeto seguindo o README.

## Regras para avançar
- Não avançar silenciosamente após falha crítica de segurança, integridade ou testes.
- Perguntar apenas quando uma decisão bloquear o trabalho ou envolver risco relevante.
- Se faltar credencial, documentar configuração e usar placeholders; nunca inventar credenciais.
- Priorizar MVP seguro e compreensível.
- Manter resumo de progresso: concluído, pendente, comandos e riscos.
