# Política de Segurança — Gestão de Time Society

## 1. Objetivo
Proteger contas, dados dos jogadores e informações financeiras. A segurança deve ser aplicada em camadas, principalmente no banco e em operações privilegiadas.

## 2. Modelo de ameaça
Considerar:
- usuário anônimo tentando ler dados privados;
- jogador tentando consultar/alterar dados de outro jogador;
- jogador tentando acessar o financeiro global;
- adulteração de IDs, parâmetros ou payloads;
- membro removido tentando reutilizar uma sessão;
- abuso de convites e autenticação;
- vazamento de segredos em logs ou Git;
- concorrência causando duplicidade de presença ou movimentação financeira.

## 3. Autenticação
- Usar Supabase Auth pelo pacote `supabase_flutter`.
- Não implementar armazenamento ou hash de senhas manualmente.
- Não registrar senhas, tokens ou segredos.
- Documentar login, logout, recuperação de acesso e convite.
- Não permitir cadastro público irrestrito por padrão.
- Configurar URLs de redirecionamento permitidas.
- Documentar criação segura do primeiro administrador.
- Tratar expiração de sessão e erros de autenticação sem expor detalhes internos.
- Não criar um mecanismo de autenticação próprio.

## 4. Autorização e RLS
- Ativar RLS em todas as tabelas acessíveis pela API Supabase.
- Criar políticas específicas para `SELECT`, `INSERT`, `UPDATE` e `DELETE`.
- Aplicar menor privilégio.
- Derivar papel e associação de fonte confiável no banco, não de valores enviados pelo app.
- Usuário não pode promover a si mesmo a administrador nem alterar seu papel.
- Verificar associação ativa ao time nas operações protegidas.
- Jogadores só leem/alteram registros próprios explicitamente permitidos.
- Financeiro global, pagamentos de terceiros, auditoria e configurações administrativas são restritos.
- Esconder telas não é controle de segurança.
- Testar chamadas diretas à API e não apenas a interface Flutter.

## 5. Chaves e segredos
- Nunca incluir `service_role`, senhas de banco ou segredos privados no app Flutter.
- A URL e a chave anon/public do Supabase podem ser usadas no cliente apenas porque são projetadas para isso; RLS deve proteger os dados.
- Guardar segredos em ambientes confiáveis e não versionar `.env` com valores reais.
- Manter `.env.example` apenas com nomes e placeholders.
- Rotacionar segredos vazados e documentar a resposta.
- Não imprimir variáveis de ambiente em logs.

## 6. Banco e integridade
- Versionar mudanças por migrations SQL.
- Usar chaves estrangeiras, restrições únicas, `CHECK` constraints e transações.
- Não confiar em validação exclusivamente no cliente.
- Usar `numeric`/`decimal` ou centavos inteiros para dinheiro; nunca `float`/`real`.
- Evitar `SECURITY DEFINER`; se indispensável, justificar, restringir permissões e fixar `search_path`.
- Validar identidade, papel, associação e entrada em funções RPC.
- Evitar SQL dinâmico inseguro.
- Documentar timestamps e fuso horário.

## 7. Operações críticas
- Presença e lista de espera devem ser atômicas ou protegidas contra concorrência.
- Não apagar pagamentos/despesas efetivados sem trilha de auditoria; preferir correção/estorno.
- Registrar ator, ação, registro afetado, horário e justificativa quando necessário.
- Não incluir dados pessoais desnecessários na auditoria.
- Confirmações na UI não substituem autorização no banco.

## 8. Uploads
Se houver escudo ou comprovante:
- validar tipo, extensão e tamanho;
- usar nomes de arquivo seguros;
- restringir envio, leitura, alteração e exclusão;
- não confiar apenas na extensão;
- manter comprovantes privados;
- usar políticas de Storage e URLs assinadas quando apropriado;
- não aceitar arquivos executáveis no fluxo normal.

## 9. Privacidade
- Coletar apenas dados necessários.
- Documentar finalidade dos campos pessoais.
- Restringir acesso a dados privados.
- Evitar dados pessoais em logs e mensagens de erro.
- Definir procedimentos de correção, desativação e exclusão compatíveis com a integridade do histórico.
- Não declarar conformidade legal total sem avaliação adequada.

## 10. Testes obrigatórios de autorização
1. Anônimo não lê dados privados.
2. Jogador A não lê nem altera dados privados do jogador B.
3. Jogador não acessa livro-caixa nem pagamentos de terceiros.
4. Jogador não consegue se promover a administrador.
5. Membro de outro time/inativo não acessa dados protegidos.
6. Administrador autorizado realiza apenas operações permitidas.
7. Alterar IDs e payloads não contorna RLS.
8. Restrições do banco rejeitam dados inválidos.
9. Operações concorrentes não ultrapassam limite de jogadores.
10. Repetir uma operação não duplica pagamento indevidamente.

Executar testes em ambiente de desenvolvimento, nunca alterando dados reais de produção.

## 11. Incidentes
Ao encontrar vulnerabilidade:
- identificar escopo e impacto;
- corrigir o caminho vulnerável;
- rotacionar segredos se necessário;
- adicionar teste de regressão;
- documentar a correção e os riscos restantes;
- não afirmar resolução sem verificação.

## 12. Checklist pré-publicação
- [ ] RLS revisado em todas as tabelas expostas.
- [ ] Nenhum segredo privado no cliente ou Git.
- [ ] Primeiro administrador e convites configurados com segurança.
- [ ] Testes de autorização executados.
- [ ] Políticas de Storage revisadas, se aplicável.
- [ ] Erros não expõem detalhes internos.
- [ ] Variáveis de ambiente configuradas na hospedagem.
- [ ] Backups e recuperação compreendidos.
- [ ] Migrations aplicadas no ambiente correto.
- [ ] README e implantação atualizados.
