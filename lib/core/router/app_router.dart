import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/subscription/presentation/pages/subscription_page.dart';
import '../../shared/widgets/main_shell.dart';

part 'app_router.g.dart';

/// Route names — use these constants instead of raw strings.
abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const settings = '/settings';
  static const subscription = '/settings/subscription';
  // ── Add your product routes below ──────────────────────────────────────
  // static const tasks = '/tasks';
  // static const taskDetail = '/tasks/:id';
}

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,

    // ── Auth Guard ─────────────────────────────────────────────────────────
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isOnboardingRoute =
          state.matchedLocation == AppRoutes.onboarding;
      final isRootRoute = state.matchedLocation == AppRoutes.splash;

      // Show onboarding on first launch
      if (!onboardingComplete && !isOnboardingRoute) {
        return AppRoutes.onboarding;
      }

      // Redirect unauthenticated users to login
      if (!isLoggedIn && !isLoginRoute && !isOnboardingRoute) {
        return '${AppRoutes.login}?redirect=${state.uri}';
      }

      // Redirect authenticated users away from auth screens
      if (isLoggedIn && (isLoginRoute || isRootRoute)) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // ── Public ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return LoginPage(redirectTo: redirect);
        },
      ),

      // ── Protected (Shell with bottom nav) ─────────────────────────────
      ShellRoute(
        builder: (_, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, __) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'subscription',
                builder: (_, __) => const SubscriptionPage(),
              ),
            ],
          ),

          // ── Add your product routes here ─────────────────────────────
          // GoRoute(
          //   path: AppRoutes.tasks,
          //   builder: (_, __) => const TaskListPage(),
          //   routes: [
          //     GoRoute(
          //       path: ':id',
          //       builder: (_, state) => TaskDetailPage(
          //         id: state.pathParameters['id']!,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    ],

    // ── Error Page ────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}

/// Tracks whether onboarding has been completed.
/// Reads from SharedPreferences via a Riverpod provider.
@riverpod
bool onboardingComplete(Ref ref) {
  // Implemented by OnboardingNotifier — injected via overrideWith in tests
  return true; // default: skip onboarding (override in onboarding_provider.dart)
}
