# Instruções para agentes de código

## Antes de começar
1. Leia `PROJECT_SPEC.md`, `DESIGN_SYSTEM.md`, `SECURITY.md` e `IMPLEMENTATION_PLAN.md`.
2. Inspecione repositório, estado Git, estrutura, dependências e comandos antes de editar.
3. Preserve mudanças existentes; não reverta ou sobrescreva alterações sem autorização.
4. Apresente diagnóstico e plano antes de mudanças extensas.

## Regras de legibilidade
- Priorize código Dart/Flutter simples, idiomático e fácil de explicar.
- Organize por funcionalidade, sem criar uma arquitetura excessiva.
- Não crie um arquivo por método ou widget trivial.
- Evite arquivos gigantes: extraia componentes quando houver responsabilidade clara ou reutilização real.
- Evite abstrações, interfaces, serviços e dependências sem benefício concreto.
- Use nomes claros, consistentes e descritivos.
- Prefira uma única forma de fazer cada tarefa.
- Ao criar uma abstração ou dependência, explique por que ela é necessária.
- Mantenha UI, acesso a dados e regras de negócio separados quando a complexidade justificar, sem impor camadas desnecessárias.

## Segurança e dados
- Siga `SECURITY.md`.
- RLS em todas as tabelas Supabase expostas.
- Nunca coloque `service_role`, segredos privados ou credenciais de servidor no app.
- Não confie em papéis ou permissões enviados pelo cliente.
- Não trate ocultar tela ou botão como autorização.
- Teste acesso anônimo, jogador, jogador de outro time/inativo e administrador.
- Proteja regras financeiras e lista de espera contra duplicidade e concorrência.
- Use migrations versionadas para alterações no banco.
- Não execute comandos destrutivos ou alterações em produção sem autorização.

## Processo por tarefa
1. Defina o objetivo da etapa.
2. Identifique arquivos e comportamentos afetados.
3. Implemente a menor mudança coerente.
4. Execute verificações seguras disponíveis: formatação, análise estática e testes.
5. Informe arquivos alterados, comandos executados, resultados reais e pendências.
6. Atualize a documentação quando arquitetura, configuração ou comportamento mudar.

## Regras gerais
- Não invente dados, credenciais, integrações ou resultados.
- Não declare que testes/build/análise passaram sem executar e verificar.
- Não adicione dependências sem justificar.
- Se faltar uma decisão não bloqueante, escolha uma opção provisória configurável e documente-a.
- Pergunte apenas quando a decisão realmente bloquear o trabalho ou envolver risco significativo.
- Se encontrar conflito entre documentos e código existente, explique o conflito e proponha resolução.

## Entrega obrigatória
Ao terminar cada tarefa, apresentar:
- resumo do que mudou;
- arquivos criados/modificados;
- comandos executados e resultados reais;
- riscos, pendências e próxima etapa recomendada.
