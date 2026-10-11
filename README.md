# Gestão de Time Society

Aplicação Flutter multiplataforma para a gestão de um time Society/Fut7/Fut6.
A primeira entrega prioriza Flutter Web responsivo; a estrutura mantém espaço
para Android e iOS. O backend planejado é Supabase Auth + PostgreSQL + RLS.

## Estado atual

- Fase 1: base Flutter, navegação, tema provisório e teste de widget.
- Fase 2: schema inicial, migrations, políticas RLS e testes SQL; assertions
  exercitadas em PostgreSQL WASM temporário.
- A aplicação ainda não inicializa o cliente Supabase nem implementa login.
- Nenhuma migration foi aplicada a um projeto remoto.

## Executar a aplicação

Instale o Flutter SDK e execute:

```powershell
flutter pub get
flutter run -d chrome
```

## Banco e Supabase

O modelo, as políticas de acesso, a configuração local, os testes e o
procedimento para conectar um projeto estão em [supabase/README.md](supabase/README.md).
Credenciais de exemplo ficam em [.env.example](.env.example); o Flutter não
carrega esse arquivo automaticamente. Não use credenciais privadas ou
`service_role` no cliente.

## Documentos do projeto

Os requisitos funcionais, de segurança e identidade visual estão na pasta
[Requirements/](Requirements/).
