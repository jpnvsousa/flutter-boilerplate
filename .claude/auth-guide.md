# Auth Guide — Flutter Boilerplate

## Provedores de Autenticação

| Provedor | Arquivo | Observação |
|----------|---------|------------|
| Google OAuth | `auth_remote_datasource.dart` | Usa `google_sign_in` + `supabase.auth.signInWithIdToken` |
| Apple Sign-In | `auth_remote_datasource.dart` | Obrigatório pela App Store. Usa `sign_in_with_apple` |
| Email Magic Link | `auth_remote_datasource.dart` | Sem senha. Link enviado via Supabase Auth |

## Fluxo de Autenticação

```
Usuário toca "Login com Google"
  → SignInWithGoogle usecase
    → AuthRemoteDataSource.signInWithGoogle()
      → GoogleSignIn().signIn() → obtém idToken + accessToken
        → supabase.auth.signInWithIdToken(provider: google)
          → Supabase cria sessão JWT
            → Trigger SQL cria perfil em profiles (se não existe)
              → AuthRepositoryImpl retorna AppUser
                → AuthNotifier emite AuthStatus.success
                  → GoRouter redireciona para /home
```

## 3 Camadas de Proteção

1. **GoRouter redirect** — verifica `authStateProvider` antes de renderizar rota protegida
2. **ConsumerWidget** — lê `currentUserProvider` para dados do usuário na UI
3. **Supabase RLS** — políticas SQL no banco impedem acesso a dados de outros usuários

## Sessão Persistente

O `supabase_flutter` persiste a sessão automaticamente via `SecureStorage`. Ao abrir o app, o SDK tenta restaurar a sessão antes de exibir a tela de login.

## Dados da Sessão

```dart
// Acessar usuário atual em qualquer ConsumerWidget:
final userAsync = ref.watch(currentUserProvider);

userAsync.when(
  data: (user) => user != null ? Text(user.email) : LoginPrompt(),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => ErrorView(message: e.toString()),
);
```

## Deep Link para Magic Link (iOS)

Configure no `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>io.supabase.flutter</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.flutter</string>
    </array>
  </dict>
</array>
```

## Novo Provedor (guia)

Para adicionar um novo provedor (ex: GitHub):

1. `AuthRemoteDataSource` — adicionar método `signInWithGitHub()`
2. `AuthRepository` — adicionar `signInWithGitHub()` à interface
3. `AuthRepositoryImpl` — implementar método
4. Criar use case: `lib/features/auth/domain/usecases/sign_in_with_github.dart`
5. `AuthNotifier` — adicionar método `signInWithGitHub()`
6. `LoginPage` — adicionar botão
