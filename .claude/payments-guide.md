# Payments Guide — Flutter Boilerplate

## Stack de Pagamentos

**RevenueCat** abstrai toda a complexidade de:
- StoreKit 2 (iOS / macOS)
- Google Play Billing Library (Android)
- Webhooks de renovação e cancelamento
- Analytics de MRR/churn

## Configuração Inicial

### 1. Dashboard RevenueCat

1. Criar projeto em [app.revenuecat.com](https://app.revenuecat.com)
2. Criar app iOS (Bundle ID: `com.suaempresa.nomeapp`)
3. Criar app Android (Package: `com.suaempresa.nomeapp`)
4. Copiar `RC_APPLE_KEY` e `RC_GOOGLE_KEY` para `.env.local`

### 2. App Store Connect

1. Criar produto de assinatura (Subscription Group)
2. Criar SKUs: `pro_monthly` e `pro_annual`
3. Vincular no RevenueCat: Products → Add Product

### 3. Google Play Console

1. Criar produto de assinatura em Monetização → Assinaturas
2. Criar planos base para os SKUs
3. Vincular no RevenueCat: Products → Add Product

### 4. Offerings e Entitlements

No RevenueCat dashboard:
1. Criar **Entitlement**: `pro_access`
2. Criar **Offering**: `default`
3. Adicionar packages: Monthly (`pro_monthly`) + Annual (`pro_annual`)
4. Vincular packages ao entitlement `pro_access`

## Verificação de Acesso (no app)

```dart
// ✅ Sempre verificar via SubscriptionX extension (app local)
final user = ref.watch(currentUserProvider).valueOrNull;
if (user?.hasAccess ?? false) {
  // Mostrar feature premium
}

// ✅ Para verificação em tempo real via RevenueCat (após compra):
final info = await Purchases.getCustomerInfo();
final hasPro = info.entitlements.active.containsKey('pro_access');
```

## Fluxo de Compra

```
Usuário toca "Upgrade to Pro"
  → SubscriptionPage carrega offerings: await Purchases.getOfferings()
    → Usuário seleciona package (Monthly ou Annual)
      → await Purchases.purchasePackage(package)
        → RevenueCat processa compra na loja
          → Webhook RevenueCat → Supabase Edge Function
            → UPDATE profiles SET plan='pro' WHERE id=userId
              → App atualiza via Riverpod (refresh currentUserProvider)
```

## Webhook (Supabase Edge Function)

**Arquivo:** `supabase/functions/revenuecat-webhook/index.ts`

Eventos tratados:
| Evento | Ação |
|--------|------|
| `INITIAL_PURCHASE` | `plan='pro'` |
| `RENEWAL` | `plan='pro'` |
| `UNCANCELLATION` | `plan='pro'` |
| `CANCELLATION` | sem ação (aguarda EXPIRATION) |
| `EXPIRATION` | `plan='free'` |
| `BILLING_ISSUE` | log (opcional: notificar usuário) |

**Configurar no RevenueCat:**
1. Project Settings → Webhooks → Add Webhook
2. URL: `https://<project>.supabase.co/functions/v1/revenuecat-webhook`
3. Authorization header: copiar `REVENUECAT_WEBHOOK_SECRET`
4. `supabase secrets set REVENUECAT_WEBHOOK_SECRET=<value>`

## Restore Purchases (obrigatório iOS)

A App Store exige que todo app com IAP tenha botão "Restore Purchases" sempre visível.
Implementado em `SubscriptionPage`:

```dart
await Purchases.restorePurchases();
```

## Teste em Sandbox

- **iOS:** Usar conta Sandbox no Settings do iPhone
- **Android:** Usar usuário de teste licenciado no Google Play Console
- RevenueCat tem dashboard de eventos para debug em tempo real
