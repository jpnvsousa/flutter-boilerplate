# 🚀 Flutter MVP Boilerplate

> Boilerplate completo para criar apps Flutter mobile prontos para produção — com autenticação, assinaturas e Clean Architecture já configurados.

---

## ✨ O que já vem pronto

| Feature | Tecnologia |
|---|---|
| 📱 Framework mobile | Flutter 3.22+ (iOS + Android) |
| 🔐 Autenticação | Supabase Auth — Google + Apple + Magic Link |
| 💾 Banco de dados | Supabase PostgreSQL + RLS |
| ⚡ Edge Functions | Supabase (Deno) — webhooks serverless |
| 💳 Pagamentos IAP | RevenueCat — iOS + Android |
| 🔔 Push Notifications | Firebase Cloud Messaging |
| 🐛 Monitoramento | Sentry Flutter |
| 🏗️ State Management | Riverpod 2 (AsyncNotifier) |
| 🧭 Navegação | GoRouter com guards de auth |
| 🧊 Models | Freezed + json_serializable |
| 💉 Injeção de dependência | get_it + injectable |
| 💽 Cache local | Drift (SQLite type-safe) |
| 🎨 Design System | AppTokens — Single Source of Truth |

---

## 🗂️ Estrutura de Pastas

```
flutter-boilerplate/
├── lib/
│   ├── core/
│   │   ├── config/env.dart              # Variáveis de ambiente
│   │   ├── theme/
│   │   │   ├── app_tokens.dart          # ⭐ Cores, espaçamento, tipografia
│   │   │   └── app_theme.dart           # ThemeData light + dark
│   │   ├── router/app_router.dart       # GoRouter + guards
│   │   ├── subscription/
│   │   │   ├── plan_limits.dart         # Limites FREE / TRIAL / PRO
│   │   │   └── subscription_service.dart
│   │   ├── di/injection.dart            # get_it + injectable
│   │   └── utils/                       # Extensions e helpers
│   ├── features/
│   │   ├── auth/                        # Clean Architecture completa
│   │   ├── onboarding/                  # First launch
│   │   ├── home/
│   │   └── settings/subscription/       # Tela de planos RevenueCat
│   ├── shared/widgets/
│   │   ├── paywall_gate.dart            # Feature gate por plano
│   │   ├── trial_banner.dart            # Banner de trial ativo
│   │   ├── main_shell.dart              # Bottom navigation
│   │   ├── loading_overlay.dart
│   │   └── error_view.dart
│   └── main.dart
├── supabase/
│   ├── migrations/                      # SQL migrations
│   └── functions/
│       ├── revenuecat-webhook/          # Atualiza plan no banco
│       └── send-notification/           # Envio push via FCM
├── test/
│   ├── unit/                            # Use cases + services
│   └── widget/                          # Widget tests
├── .env.example                         # Template de variáveis
├── .fvmrc                               # Flutter 3.22.3 fixado
├── analysis_options.yaml                # Linting estrito
├── Makefile                             # Comandos padronizados
└── BOILERPLATE_MANUAL.md               # Guia completo de uso
```

---

## ⚡ Início Rápido

### 1. Pré-requisitos

```bash
flutter --version   # 3.22+
fvm --version       # Flutter Version Manager
supabase --version  # Supabase CLI
```

### 2. Clonar e configurar

```bash
git clone https://github.com/jpnvsousa/flutter-boilerplate.git
cd flutter-boilerplate

# Copiar variáveis de ambiente
cp .env.example .env.local
# Editar .env.local com suas chaves (Supabase, RevenueCat, Sentry)

# Instalar dependências e rodar code generation
make setup
```

### 3. Configurar banco de dados

```bash
supabase db push   # Aplica migrations (profiles + RLS + trigger)
```

### 4. Rodar o app

```bash
make run
# ou
flutter run --dart-define-from-file=.env.local
```

---

## 🔑 Variáveis de Ambiente

Crie `.env.local` a partir do `.env.example`:

```env
SUPABASE_URL=https://xxxxxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
RC_APPLE_KEY=appl_...
RC_GOOGLE_KEY=goog_...
SENTRY_DSN=https://xxx@sentry.io/xxx
ENVIRONMENT=development
```

Contas necessárias:
- [Supabase](https://supabase.com) — gratuito
- [RevenueCat](https://revenuecat.com) — gratuito até U$2.5k MRR
- [Firebase](https://firebase.google.com) — gratuito (Spark)
- [Sentry](https://sentry.io) — gratuito (5k erros/mês)

---

## 📋 Comandos disponíveis

```bash
make setup          # Instala dependências + roda code generation
make gen            # Roda build_runner (Freezed, Riverpod, Injectable)
make run            # Roda em modo debug
make test           # Todos os testes com cobertura
make check          # Lint + testes + verificação de hex hardcoded
make build-android  # Gera AAB release
make build-ios      # Gera IPA release
make db-push        # Aplica migrations no Supabase
make functions-deploy  # Deploy das Edge Functions
```

---

## 💳 Sistema de Planos

```
FREE   → limites definidos em PlanLimits (ex: máximo 3 itens)
TRIAL  → 14 dias com acesso total (criado automaticamente no signup)
PRO    → pago via RevenueCat, acesso total
```

Fluxo automático:
1. Usuário cria conta → `plan = 'trial'`, `trial_ends_at = now + 14 dias`
2. Trial ativo → banner com countdown + acesso total
3. Trial expirado → redirecionado para paywall
4. Paga → webhook RevenueCat → `plan = 'pro'`
5. Cancela → `plan = 'free'` na expiração

---

## 🏗️ Clean Architecture por Feature

Cada feature segue esta estrutura obrigatória:

```
lib/features/<feature>/
├── data/
│   ├── datasources/    # Acesso remoto (Supabase) e local (Drift)
│   ├── models/         # @JsonSerializable — mapeamento JSON
│   └── repositories/   # @LazySingleton — implementação
├── domain/
│   ├── entities/       # @freezed — imutáveis
│   ├── repositories/   # abstract interface — contrato
│   └── usecases/       # @injectable — uma ação por arquivo
└── presentation/
    ├── providers/      # @riverpod — state management
    ├── pages/
    └── widgets/
```

Após criar arquivos com annotations:
```bash
make gen
```

---

## 🎨 Design System

**Regra:** nunca use `Color(0xFF...)` fora de `app_tokens.dart`.

```dart
// ✅ Correto
Container(color: AppTokens.primary)
Text('Hello', style: TextStyle(color: AppTokens.grey500))

// ❌ Errado
Container(color: Color(0xFF6C63FF))
```

Todos os tokens em `lib/core/theme/app_tokens.dart`:
- Cores (brand, neutros, semânticos, light/dark)
- Espaçamento (`spacing4` → `spacing80`)
- Border radius (`radiusS` → `radiusFull`)
- Tipografia (tamanhos, pesos, família)
- Animações (durations, curves)

---

## 🔒 Autenticação

Providers disponíveis:
- **Google Sign-In** — via `google_sign_in` + Supabase
- **Apple Sign-In** — obrigatório pela App Store (Sign in with Apple)
- **Magic Link** — email sem senha via Supabase Auth

Proteção de rotas em 2 camadas:
1. **GoRouter `redirect`** — verifica `authStateProvider` antes de renderizar
2. **Supabase RLS** — políticas SQL impedem acesso a dados de outros usuários

---

## 📦 Personalizar para seu produto

1. Edite `BOILERPLATE_MANUAL.md` — preencha a seção `[MEU PRODUTO]`
2. Ajuste limites de plano em `lib/core/subscription/plan_limits.dart`
3. Adicione suas entidades em `supabase/migrations/20240101000001_product_tables.sql`
4. Crie suas features em `lib/features/<sua-feature>/` seguindo o padrão Clean Architecture
5. Adicione rotas em `lib/core/router/app_router.dart`
6. Adicione tabs em `lib/shared/widgets/main_shell.dart`
7. Atualize cores em `lib/core/theme/app_tokens.dart`

---

## 🧪 Testes

```bash
make test           # Todos os testes
make test-unit      # Apenas unitários
make test-widget    # Apenas widget tests
```

Testes incluídos:
- `SignInWithGoogle` use case
- `SubscriptionService` (trial, acesso, dias restantes)
- `TrialBanner` widget

---

## 📚 Documentação adicional

| Arquivo | Conteúdo |
|---|---|
| `BOILERPLATE_MANUAL.md` | Guia completo de 10 etapas para criar seu MVP |
| `.claude/auth-guide.md` | Fluxo de autenticação detalhado |
| `.claude/payments-guide.md` | Setup completo do RevenueCat |
| `.claude/project-overview.md` | Visão geral da arquitetura |
| `CLAUDE.md` | Contexto para desenvolvimento com Claude Code |

---

## 📄 Licença

MIT — use à vontade para seus projetos.
