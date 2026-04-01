# Flutter Boilerplate — Claude Code Context

Este é um boilerplate Flutter MVP com autenticação, pagamentos e gerenciamento de features prontos para produção.

## Stack do Projeto

- **Framework:** Flutter 3.22+ com Dart 3.4+
- **Backend:** Supabase (PostgreSQL + Auth + Edge Functions)
- **State Management:** Riverpod 2 (AsyncNotifier / StateNotifier)
- **Navegação:** GoRouter com guards de autenticação
- **Pagamentos:** RevenueCat (IAP — iOS + Android)
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Erros:** Sentry Flutter
- **Models:** Freezed + json_serializable
- **DI:** get_it + injectable
- **Cache Local:** Drift (SQLite type-safe)
- **Code Gen:** build_runner

## Regras de Arquitetura

1. **Clean Architecture Feature-First:** `lib/features/<feature>/{data,domain,presentation}/`
2. **Nunca hex hardcoded:** Sempre usar `AppTokens.*` — nunca `Color(0xFF...)` fora de `app_tokens.dart`
3. **Models imutáveis:** Usar `@freezed` para todas as entidades de domínio
4. **Repositórios abstratos:** Domain layer define interfaces, data layer implementa
5. **Use cases:** Um arquivo por ação (Single Responsibility)
6. **Providers Riverpod:** Usar `@riverpod` annotation + `build_runner` para geração
7. **Injeção via get_it:** Nunca usar `BuildContext` para injetar serviços
8. **Versões fixas:** Sem `^` nas dependências críticas em `pubspec.yaml`

## Arquivos-Chave

| Arquivo | Propósito |
|---------|-----------|
| `lib/core/config/env.dart` | Variáveis de ambiente via `--dart-define-from-file` |
| `lib/core/theme/app_tokens.dart` | **Single Source of Truth** de cores, espaçamento, tipografia |
| `lib/core/theme/app_theme.dart` | ThemeData usando apenas AppTokens |
| `lib/core/router/app_router.dart` | GoRouter com guards de autenticação e onboarding |
| `lib/core/subscription/subscription_service.dart` | Extensões de acesso/trial no AppUser |
| `lib/core/subscription/plan_limits.dart` | Limites por plano (FREE/TRIAL/PRO) |
| `lib/core/di/injection.dart` | Setup do get_it via injectable |
| `lib/shared/widgets/paywall_gate.dart` | Widget de gate de feature por plano |
| `lib/shared/widgets/trial_banner.dart` | Banner de trial com contador de dias |
| `lib/shared/widgets/main_shell.dart` | Shell com bottom navigation |
| `supabase/migrations/` | Migrations SQL do Supabase |
| `supabase/functions/revenuecat-webhook/` | Edge Function para webhooks RevenueCat |
| `supabase/functions/send-notification/` | Edge Function para push via FCM |
| `Makefile` | Comandos padronizados: `make setup`, `make gen`, `make test` |

## Sistema de Planos

```dart
// FREE:  limites definidos em PlanLimits.limits['free']
// TRIAL: 14 dias, acesso total (trialEndsAt = now + 14 days no signup)
// PRO:   pago via RevenueCat, acesso total
```

Fluxo:
1. Signup → `plan='trial'`, `trial_ends_at=now+14days` (trigger SQL)
2. Trial ativo → acesso total + `TrialBanner` com countdown
3. Trial expirado → redirecionado para paywall
4. Paga → webhook RevenueCat → `plan='pro'`
5. Cancela → `plan='free'` na expiração (webhook `EXPIRATION`)

## Estrutura por Feature (padrão obrigatório)

```
lib/features/<feature>/
├── data/
│   ├── datasources/<feature>_remote_datasource.dart
│   ├── models/<feature>_model.dart           (@JsonSerializable)
│   └── repositories/<feature>_repository_impl.dart  (@LazySingleton)
├── domain/
│   ├── entities/<feature>_entity.dart        (@freezed)
│   ├── repositories/<feature>_repository.dart (abstract interface)
│   └── usecases/
│       ├── get_<feature>s.dart               (@injectable)
│       ├── create_<feature>.dart
│       ├── update_<feature>.dart
│       └── delete_<feature>.dart
└── presentation/
    ├── providers/<feature>_provider.dart     (@riverpod)
    ├── pages/
    └── widgets/
```

## Variáveis de Ambiente

```bash
flutter run --dart-define-from-file=.env.local
```

Necessárias:
- `SUPABASE_URL` — URL do projeto Supabase
- `SUPABASE_ANON_KEY` — Chave pública Supabase
- `RC_APPLE_KEY` — RevenueCat key iOS
- `RC_GOOGLE_KEY` — RevenueCat key Android
- `SENTRY_DSN` — DSN do Sentry

## Comandos Essenciais

```bash
make setup        # instala deps + roda build_runner
make gen          # roda build_runner (Freezed, Riverpod, Injectable, Drift)
make test         # todos os testes com cobertura
make check        # lint + testes + check hex hardcoded
make build-android # AAB release
make build-ios     # IPA release
```

## Code Generation

Após criar/editar arquivos com `@freezed`, `@riverpod`, `@injectable` ou models Drift:

```bash
make gen
# ou
dart run build_runner build --delete-conflicting-outputs
```

Arquivos gerados (**nunca editar manualmente**):
- `*.g.dart` — json_serializable, Riverpod
- `*.freezed.dart` — Freezed models
- `lib/core/di/injection.config.dart` — Injectable DI config

## Primeiro Setup (Guia para novo desenvolvedor)

1. `cp .env.example .env.local` e preencher as variáveis
2. **Supabase** — criar projeto em supabase.com → copiar URL e anon key
3. **Supabase migrations** — `supabase db push` (aplica schema + trigger)
4. **RevenueCat** — criar projeto, vincular App Store + Google Play → copiar keys
5. **Firebase** — criar projeto, baixar `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
6. **Sentry** — criar projeto Flutter → copiar DSN
7. `fvm use 3.22.x` (se usando FVM)
8. `make setup` (instala deps + code gen)
9. `flutter run --dart-define-from-file=.env.local`

## Supabase Edge Functions

```bash
# Deploy todas as Edge Functions
make functions-deploy

# Testar localmente
supabase functions serve

# Configurar secrets
supabase secrets set REVENUECAT_WEBHOOK_SECRET=xxx
supabase secrets set FCM_SERVER_KEY=xxx
```

## Decisões Importantes

- **FVM obrigatório** para fixar versão do Flutter
- **Supabase** no lugar de Firebase Firestore (SQL + RLS nativo)
- **RevenueCat** abstrai StoreKit iOS e Google Play Billing
- **Sign in with Apple** obrigatório pela App Store para apps com social login
- **Restore purchases** sempre visível na tela de assinatura (exigido pela App Store)
- **Drift** para cache local offline-first (type-safe SQLite)
- **Sentry** preferido ao Firebase Crashlytics (melhor dashboard, agnóstico)
- **Sem `^`** nas dependências críticas em pubspec.yaml

## Integração Figma MCP (opcional)

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/figma-mcp-server@latest"]
    }
  }
}
```

Use `get_design_context` com URLs de componentes Figma para extrair código pixel-perfect com `AppTokens`.
