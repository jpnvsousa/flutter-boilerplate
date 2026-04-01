import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'core/config/env.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Background FCM handler — must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ──────────────────────────────────────────────────────────────
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ── Supabase ──────────────────────────────────────────────────────────────
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // ── RevenueCat ───────────────────────────────────────────────────────────
  await Purchases.setLogLevel(LogLevel.debug);
  final purchasesConfig = PurchasesConfiguration(
    // Selects key based on platform at runtime
    Theme.of(
          // ignore: use_build_context_synchronously
          navigatorKey.currentContext!,
        ).platform ==
        TargetPlatform.iOS
    ? Env.revenuecatAppleKey
    : Env.revenuecatGoogleKey,
  );
  await Purchases.configure(purchasesConfig);

  // ── Dependency Injection ──────────────────────────────────────────────────
  await configureDependencies();

  // ── Sentry ────────────────────────────────────────────────────────────────
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = Env.sentryDsn
        ..tracesSampleRate = 0.2
        ..environment = Env.environment;
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: AppRoot(),
      ),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flutter Boilerplate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
