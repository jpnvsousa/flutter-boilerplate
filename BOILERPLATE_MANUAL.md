# BOILERPLATE MANUAL — Flutter MVP

> **Objetivo:** Qualquer pessoa pode usar este boilerplate para criar um MVP de app mobile completo com Flutter.
> Basta substituir a seção `[MEU PRODUTO]` no final e rodar o prompt no Claude Code.

---

## PRÉ-REQUISITOS

Antes de começar, instale estas ferramentas na sua máquina:

| Ferramenta | Versão mínima | Como instalar |
|---|---|---|
| **Flutter SDK** | v3.22+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| **Dart** | v3.4+ | Vem com o Flutter |
| **Git** | v2+ | [git-scm.com](https://git-scm.com) |
| **GitHub CLI** | v2+ | `brew install gh` ou [cli.github.com](https://cli.github.com) |
| **Xcode** | v15+ | App Store (só Mac, para iOS) |
| **Android Studio** | latest | [developer.android.com](https://developer.android.com/studio) |
| **Supabase CLI** | latest | `brew install supabase/tap/supabase` |
| **FVM** | latest | `brew tap leoafarias/fvm && brew install fvm` |

Verifique a instalação:
```bash
flutter --version    # deve mostrar v3.22+
dart --version       # deve mostrar v3.4+
git --version
gh --version
supabase --version
fvm --version
```

**Contas necessárias** (crie antes de começar):
- [GitHub](https://github.com) — repositório
- [Supabase](https://supabase.com) — PostgreSQL + Auth + Edge Functions
- [RevenueCat](https://revenuecat.com) — IAP / assinaturas
- [Google Play Console](https://play.google.com/console) — publicação Android
- [Apple Developer Program](https://developer.apple.com/programs/) — publicação iOS (U$99/ano)
- [Firebase](https://firebase.google.com) — Push Notifications (gratuito)
- [Sentry](https://sentry.io) — monitoramento de erros (free tier)

---

## ETAPAS DE BUILD (ordem obrigatória)

### ETAPA 0 — INFRAESTRUTURA

1. **Clonar este boilerplate** em um novo repositório
2. **Criar projeto no Supabase** → copiar URL e anon key
3. **Criar projeto no Firebase** → baixar `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
4. **Criar projeto no RevenueCat** → vincular App Store Connect + Google Play Console
5. **Configurar FVM:** `fvm use 3.22.x` → confirma `.fvmrc`
6. **Configurar bundle IDs:**
   - iOS: `com.suaempresa.nomeapp` (em `ios/Runner.xcodeproj`)
   - Android: `com.suaempresa.nomeapp` (em `android/app/build.gradle`)
7. **Copiar env:** `cp .env.example .env.local` e preencher variáveis
8. **Rodar:** `make setup`

> ✅ **Resultado esperado:** App rodando no simulador iOS e emulador Android.

---

### ETAPA 1 — BANCO DE DADOS (Supabase)

1. Aplicar migrations: `supabase db push`
2. Verificar na dashboard do Supabase:
   - Tabela `profiles` criada com RLS ativo
   - Trigger `on_auth_user_created` ativo
3. Editar `supabase/migrations/20240101000001_product_tables.sql` com suas entidades
4. Reaplicar: `supabase db push`

**Tabelas obrigatórias já criadas:**
- `profiles` — estende `auth.users` com `plan`, `trial_ends_at`, `fcm_token`
- Trigger auto-cria perfil com `plan='trial'` e `trial_ends_at=now()+14days`

---

### ETAPA 2 — AUTENTICAÇÃO

Já implementado. Para ativar:

1. **Google Sign-In (iOS):** Adicionar `GoogleService-Info.plist` no Xcode
2. **Google Sign-In (Android):** Adicionar `google-services.json` em `android/app/`
3. **Apple Sign-In:** Habilitar capability "Sign in with Apple" no Xcode
4. **Magic Link:** Configurar callback URL no Supabase Auth settings:
   - `io.supabase.flutter://login-callback`

**Arquivos de auth:**
- `lib/features/auth/` — Clean Architecture completa
- `lib/core/router/app_router.dart` — guards automáticos

---

### ETAPA 3 — TRIAL E ASSINATURA

Já implementado. Verificar:
- `lib/core/subscription/plan_limits.dart` — ajustar limites para seu produto
- `lib/core/subscription/subscription_service.dart` — extensões `hasAccess`, `isTrialActive`, etc.
- `lib/shared/widgets/trial_banner.dart` — já integrado na `HomePage`

---

### ETAPA 4 — PAYWALL E LIMITES

Já implementado via `PaywallGate`. Para usar em suas features:

```dart
// Em qualquer widget que precisa de paywall:
PaywallGate(
  resource: 'items',          // chave em PlanLimits.limits
  currentCount: items.length, // contagem atual
  child: CreateItemButton(),  // mostrado se tem acesso
)
```

Edite os limites em `lib/core/subscription/plan_limits.dart`.

---

### ETAPA 5 — PAGAMENTOS (RevenueCat)

1. **Configurar produtos** no RevenueCat dashboard:
   - Entitlement: `pro_access`
   - Offering: `default` com packages Monthly + Annual
2. **Deploy webhook:** `supabase functions deploy revenuecat-webhook`
3. **Configurar secret:** `supabase secrets set REVENUECAT_WEBHOOK_SECRET=xxx`
4. **Registrar webhook** no RevenueCat: Project Settings → Webhooks
5. **Testar** com sandbox accounts

---

### ETAPA 6 — FEATURES DO PRODUTO

Criar suas features seguindo o padrão Clean Architecture:

```
lib/features/<sua-feature>/
├── data/
│   ├── datasources/<feature>_remote_datasource.dart
│   ├── models/<feature>_model.dart               (@JsonSerializable)
│   └── repositories/<feature>_repository_impl.dart (@LazySingleton)
├── domain/
│   ├── entities/<feature>_entity.dart             (@freezed)
│   ├── repositories/<feature>_repository.dart     (interface)
│   └── usecases/ (um arquivo por ação)
└── presentation/
    ├── providers/<feature>_provider.dart           (@riverpod)
    ├── pages/
    └── widgets/
```

Após criar novos arquivos com annotations: `make gen`

---

### ETAPA 7 — NAVEGAÇÃO

Adicionar rotas em `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/tasks',
  builder: (_, __) => const TaskListPage(),
),
```

Adicionar tabs em `lib/shared/widgets/main_shell.dart`.

---

### ETAPA 8 — ONBOARDING

Editar slides em `lib/features/onboarding/presentation/pages/onboarding_page.dart`:

```dart
static const _pages = [
  _OnboardingSlide(
    icon: Icons.your_icon,
    title: 'Seu título',
    subtitle: 'Sua descrição.',
  ),
  // ...
];
```

---

### ETAPA 9 — NOTIFICAÇÕES PUSH

1. Adicionar `google-services.json` e `GoogleService-Info.plist`
2. Configurar permissões no `AppDelegate.swift` (iOS) e `AndroidManifest.xml` (Android)
3. Deploy da Edge Function: `supabase functions deploy send-notification`
4. Configurar `supabase secrets set FCM_SERVER_KEY=xxx`
5. Salvar FCM token ao login: `repository.updateFcmToken(userId, token)`

---

### ETAPA 10 — CONFIGURAÇÃO FINAL

```bash
make check           # lint + testes + check hex hardcoded
make build-android   # gera AAB release
make build-ios       # gera IPA release
```

**Verificações antes de publicar:**
- [ ] Ícone do app configurado (`flutter_launcher_icons`)
- [ ] Splash screen configurada (`flutter_native_splash`)
- [ ] Bundle ID correto em iOS e Android
- [ ] Versão e build number incrementados em `pubspec.yaml`
- [ ] Todas as variáveis de ambiente de produção configuradas
- [ ] Webhook RevenueCat apontando para URL de produção
- [ ] Sentry em modo `production`
- [ ] `flutter analyze` sem warnings

---

## STACK OBRIGATÓRIA

| Tecnologia | Função |
|---|---|
| **Flutter 3.22+** | Framework mobile (iOS + Android) |
| **Dart 3.4+** | Linguagem |
| **Supabase** | Backend: PostgreSQL + Auth + Edge Functions |
| **Riverpod 2** | State management |
| **GoRouter** | Navegação declarativa |
| **Freezed + json_serializable** | Models imutáveis + serialização |
| **Drift** | Cache local offline-first (SQLite) |
| **Dio** | HTTP client |
| **RevenueCat** | Assinaturas e in-app purchases |
| **Firebase Messaging** | Push notifications |
| **Sentry** | Monitoramento de erros |
| **get_it + injectable** | Injeção de dependências |

---

## VARIÁVEIS DE AMBIENTE

```bash
# Rodar localmente
flutter run --dart-define-from-file=.env.local

# Build de produção
flutter build appbundle --dart-define-from-file=.env.production
```

Variáveis necessárias (ver `.env.example`):
```
SUPABASE_URL          https://xxx.supabase.co
SUPABASE_ANON_KEY     eyJ...
RC_APPLE_KEY          appl_...
RC_GOOGLE_KEY         goog_...
SENTRY_DSN            https://xxx@sentry.io/xxx
ENVIRONMENT           development | production
```

---

## DECISÕES E AJUSTES

1. **FVM obrigatório** — Fixa versão do Flutter entre devs e CI/CD
2. **Supabase no lugar de Firebase Firestore** — SQL + RLS nativo + Edge Functions serverless
3. **RevenueCat no lugar de IAP direto** — Abstrai StoreKit + Play Billing, webhooks, analytics
4. **Riverpod 2 (AsyncNotifier)** — Type-safe, async nativo, sem BuildContext nos providers
5. **GoRouter** — Declarativo, deep links, guards simples via `redirect`
6. **Freezed para models** — Imutabilidade, `copyWith`, equality, serialização automática
7. **get_it + injectable** — DI sem BuildContext, testável
8. **Apple Sign-In obrigatório** — App Store exige se o app tem qualquer login social
9. **Restore Purchases visível** — App Store exige em apps com IAP
10. **Drift para cache local** — SQLite type-safe, migrations, dados relacionais
11. **analysis_options estrito** — Zero `dynamic` implícito, `avoid_dynamic_calls`, etc.
12. **Sentry preferido** — Melhor dashboard que Firebase Crashlytics, agnóstico a Firebase
13. **`make gen` padronizado** — Todos os devs usam o mesmo comando para code generation
14. **Sem `^` nas dependências críticas** — Evita breaking changes acidentais
15. **Edge Functions para webhooks** — Supabase Deno Edge Functions, sem servidor dedicado
16. **AppTokens como Single Source of Truth** — Zero hex hardcoded fora de `app_tokens.dart`

---

## PROMPT PARA O CLAUDE CODE

Cole este prompt no Claude Code após substituir `[MEU PRODUTO]`:

```
Você é um engenheiro Flutter sênior especialista em Clean Architecture e Riverpod.
Este projeto usa o flutter-boilerplate. Siga o BOILERPLATE_MANUAL.md e o CLAUDE.md.

REGRAS:
- Use APENAS as tecnologias da stack obrigatória
- Nunca use hex hardcoded fora de AppTokens
- Sempre crie use cases no padrão Single Responsibility
- Sempre use @freezed para entities e @riverpod para providers
- Rode make gen após criar/editar arquivos com annotations
- Crie testes unitários para todos os use cases

Ao terminar cada etapa, confirme com "✅ Etapa X concluída" antes de avançar.
```

---

## [MEU PRODUTO] — SUBSTITUA ABAIXO

```
Nome do produto: [NOME]
Bundle ID: com.[suaempresa].[nomeapp]
Headline: "[FRASE PRINCIPAL DA ONBOARDING]"
Subtítulo: "[SUBTÍTULO]"
Plataformas: iOS e Android

Features:
1. [Feature principal]
2. [Feature 2]
3. [Feature 3]
4. [Feature 4]
5. [Feature 5]

Entidades extras (além de profiles):
- [Entidade1] (campos: id uuid, user_id uuid, nome text, created_at timestamptz)
- [Entidade2] (campos: ...)

Permissões necessárias:
- [ ] Câmera
- [ ] Microfone
- [ ] Notificações push
- [ ] Localização
- [ ] Galeria de fotos

Limites por plano:
- FREE:  [descreva — ex: máximo 3 itens]
- TRIAL (14 dias): tudo ilimitado
- PRO:   tudo ilimitado

Preço sugerido:
- PRO Mensal: R$ [VALOR]/mês
- PRO Anual:  R$ [VALOR]/ano (destaque como "melhor custo-benefício")

Cores:
- Primária:   [hex]
- Fundo:      [hex]
- Surface:    [hex]
- Acento:     [hex]
- Texto:      [hex]

Fonte: [Inter / Poppins / Nunito / outra Google Font]
```
