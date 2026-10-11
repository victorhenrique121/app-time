# Design System — Gestão de Time Society (Flutter)

## 1. Objetivo
Definir uma identidade visual coesa, esportiva, moderna, legível e fácil de manter. A primeira interface será Flutter Web responsiva, com possibilidade de reutilizar os componentes em Android e iOS.

## 2. Marca do time e marca do aplicativo
- São conceitos separados.
- Não inventar nome, escudo ou cores oficiais do time.
- Até o usuário fornecer a identidade oficial, usar identidade provisória configurável.
- Permitir fallback visual quando não houver escudo.
- Configurações da marca devem vir de dados do time, não de textos duplicados em várias telas.

## 3. Paleta provisória
Ponto de partida: esportivo moderno, verde profundo, destaque verde e fundos neutros. Esta paleta não é identidade oficial e deve ficar centralizada no tema.

- Primária: `#173D2D`
- Primária escura: `#102B20`
- Destaque: `#A3D65C`
- Fundo: `#F6F8F5`
- Superfície: `#FFFFFF`
- Texto principal: `#17211B`
- Texto secundário: `#5E6B62`
- Borda: `#DCE4DD`
- Sucesso: `#237A45`
- Aviso: `#8A5A00`
- Erro: `#B42318`
- Informação: `#175CD3`

Verificar contraste antes de usar cores em texto. Não comunicar estados apenas por cor.

## 4. Implementação Flutter
- Centralizar cores, tipografia e estilos em `ThemeData`/`ColorScheme` e arquivos de tema.
- Criar componentes compartilhados apenas quando houver reutilização ou necessidade clara de consistência.
- Evitar valores de cor, espaçamento e tipografia espalhados pelas telas.
- Não misturar soluções de estilização concorrentes.
- Usar Material 3 como ponto de partida e personalizar com moderação.

## 5. Tipografia e espaçamento
- Usar uma família sans-serif legível; preferir uma fonte do sistema ou adicionar fonte externa apenas com justificativa.
- Definir hierarquia para título de página, seção, corpo, legenda e texto auxiliar.
- Evitar textos pequenos em tabelas e informações financeiras.
- Usar escala consistente de espaçamento, por exemplo múltiplos de 4 ou 8.
- Manter áreas clicáveis confortáveis e layouts sem excesso de cartões.

## 6. Componentes
Construir e reutilizar, conforme necessidade:
- botões primários, secundários e destrutivos;
- campos e formulários;
- cartões informativos;
- listas e tabelas adaptáveis;
- etiquetas de estado;
- diálogos de confirmação;
- navegação;
- mensagens de sucesso/erro;
- estados de carregamento, vazio e falha;
- avatar/escudo com fallback;
- filtros e paginação quando necessários.

Não criar todos os componentes antecipadamente. Evitar abstrair widgets triviais usados uma única vez.

## 7. Ícones e imagens
- Usar uma única biblioteca de ícones consistente, ou ícones Material padrão.
- Não usar emojis como substitutos de ícones funcionais.
- Imagens devem agregar valor e não ser necessárias para entender uma ação.
- Não depender de URLs externas frágeis para elementos essenciais.
- Validar tipo e tamanho dos uploads.
- Comprovantes financeiros não devem ser publicamente acessíveis por padrão.
- Não usar escudos, fotos ou marcas de terceiros sem autorização adequada.
- Placeholders devem ser fáceis de substituir.

## 8. Navegação e telas
Planejar, conforme permissões:
- login e recuperação de acesso;
- painel;
- partidas e detalhes;
- confirmações/lista de espera;
- jogadores/membros para administrador;
- minhas cobranças e pagamentos para jogador;
- financeiro/relatórios para administrador;
- histórico;
- configurações e perfil;
- telas de acesso negado e erro.

Esconder opções irrelevantes melhora a experiência, mas não substitui autorização no banco.

## 9. Responsividade Flutter Web
- Priorizar celular, mas validar tablet e desktop.
- Usar layouts adaptativos em vez de assumir uma largura fixa.
- Evitar tabelas largas em telas pequenas; adaptar para listas/cartões.
- Formularios devem ter rótulos persistentes, não apenas placeholders.
- Não depender de hover.
- Testar larguras estreitas e amplas, além de navegação por teclado.

## 10. Acessibilidade
- Foco visível e ordem de navegação lógica.
- Rótulos e nomes acessíveis para botões de ícone.
- Mensagens de erro claras.
- Contraste suficiente.
- Não depender apenas da cor para status.
- Respeitar preferências de movimento reduzido quando houver animações.
- Evitar animações que atrapalhem tarefas frequentes.

## 11. Tema escuro
Tema escuro é opcional para o MVP. Se implementado, centralizar os tokens por tema e testar contraste e estados em ambos. Não duplicar telas por causa do tema.

## 12. Regras de qualidade
- Evitar aparência genérica sem personalidade.
- Evitar excesso de gradientes, sombras e animações.
- Priorizar clareza e consistência.
- Não apresentar dados fictícios como reais.
- Validar primeiro uma tela representativa e o conjunto de componentes-base antes de replicar o padrão.
