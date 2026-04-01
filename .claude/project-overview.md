# Project Overview — Flutter Boilerplate

## O que é este projeto?

Um boilerplate Flutter Mobile pronto para produção com:
- **Autenticação** (Google + Apple + Magic Link)
- **Sistema de planos** (Free / Trial / Pro)
- **Pagamentos IAP** via RevenueCat
- **Push Notifications** via Firebase
- **Backend serverless** via Supabase
- **Monitoramento de erros** via Sentry
- **Clean Architecture** feature-first

## Estrutura de Pastas

```
flutter-boilerplate/
├── lib/
│   ├── core/                          # Infraestrutura transversal
│   │   ├── config/env.dart            # --dart-define env vars
│   │   ├── theme/
│   │   │   ├── app_tokens.dart        # ⭐ Single Source of Truth (cores, espaçamento)
│   │   │   └── app_theme.dart         # ThemeData usando AppTokens
│   │   ├── router/app_router.dart     # GoRouter + guards
│   │   ├── subscription/
│   │   │   ├── plan_limits.dart       # Limites FREE/TRIAL/PRO
│   │   │   └── subscription_service.dart  # Extensions SubscriptionX
│   │   ├── di/injection.dart          # get_it + injectable setup
│   │   └── utils/
│   │       ├── extensions/            # BuildContext, String extensions
│   │       └── helpers/               # DateHelpers
│   ├── features/
│   │   ├── auth/                      # Clean Arch completa
│   │   ├── onboarding/                # First launch slides
│   │   ├── home/                      # Dashboard principal
│   │   └── settings/
│   │       └── subscription/          # Tela de planos + RevenueCat UI
│   ├── shared/
│   │   └── widgets/
│   │       ├── main_shell.dart        # Shell com bottom nav
│   │       ├── paywall_gate.dart      # Feature gate por plano
│   │       ├── trial_banner.dart      # Banner de trial ativo
│   │       ├── loading_overlay.dart   # Full-screen loader
│   │       └── error_view.dart        # Estado de erro reutilizável
│   └── main.dart                      # Bootstrap (Firebase, Supabase, RevenueCat, Sentry)
├── supabase/
│   ├── migrations/                    # SQL migrations
│   └── functions/
│       ├── revenuecat-webhook/        # Webhook RevenueCat → atualiza plan
│       └── send-notification/         # Envio push via FCM server-side
├── test/
│   ├── unit/                          # Use cases + services
│   └── widget/                        # Widget tests
├── .env.example                       # Template de variáveis
├── .fvmrc                             # Versão Flutter fixada
├── analysis_options.yaml              # Linting estrito
├── Makefile                           # Comandos padronizados
└── CLAUDE.md                          # Este contexto para o Claude Code
```

## Padrões-Chave

### AsyncNotifier Pattern (Riverpod)
```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  FutureOr<List<Item>> build() => _loadItems();

  Future<void> create(String title) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.create(title));
  }
}
```

### Repository Pattern
```dart
// Domain (interface)
abstract interface class ItemRepository {
  Future<List<Item>> getAll(String userId);
  Future<Item> create(CreateItemInput input);
}

// Data (implementation) — anotada com @LazySingleton
@LazySingleton(as: ItemRepository)
class ItemRepositoryImpl implements ItemRepository { ... }
```

### PaywallGate Pattern
```dart
// Bloqueia feature com gate de upgrade
PaywallGate(
  resource: 'items',
  currentCount: items.length,
  child: CreateItemFAB(),
)
```

## Dependências Críticas (versões fixas — sem `^`)

```yaml
supabase_flutter: 2.5.6
purchases_flutter: 7.4.0
flutter_riverpod: 2.5.1
go_router: 14.2.0
```
