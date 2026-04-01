import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) => ListView(
          children: [
            // ── Profile Section ─────────────────────────────────────────
            if (user != null) ...[
              Padding(
                padding: const EdgeInsets.all(AppTokens.spacing24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    const SizedBox(width: AppTokens.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName ?? 'No name',
                            style: context.textTheme.titleLarge,
                          ),
                          Text(
                            user.email,
                            style: context.textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppTokens.spacing4),
                          _PlanBadge(plan: user.plan),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],

            // ── Subscription ─────────────────────────────────────────────
            _SettingsTile(
              icon: Icons.star_outline_rounded,
              title: 'Subscription',
              subtitle: 'Manage your plan',
              onTap: () => context.push(AppRoutes.subscription),
            ),

            const Divider(),

            // ── App ───────────────────────────────────────────────────────
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage push notifications',
              onTap: () {/* Open notifications settings */},
            ),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: 'Theme and display',
              onTap: () {/* Open appearance settings */},
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Privacy',
              subtitle: 'Data and privacy settings',
              onTap: () {/* Open privacy settings */},
            ),

            const Divider(),

            // ── Support ───────────────────────────────────────────────────
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {/* Open support */},
            ),
            _SettingsTile(
              icon: Icons.star_rate_outlined,
              title: 'Rate the app',
              onTap: () {/* Open app store */},
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () => showAboutDialog(context: context),
            ),

            const Divider(),

            // ── Sign Out ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppTokens.spacing16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authNotifier.signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                icon: const Icon(Icons.logout, color: AppTokens.error),
                label: const Text(
                  'Sign out',
                  style: TextStyle(color: AppTokens.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTokens.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTokens.grey600),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, color: AppTokens.grey400),
      onTap: onTap,
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.plan});

  final String plan;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (plan) {
      'pro' => ('PRO', AppTokens.primary, Colors.white),
      'trial' => ('TRIAL', AppTokens.warningLight, AppTokens.warning),
      _ => ('FREE', AppTokens.grey100, AppTokens.grey600),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacing8,
        vertical: AppTokens.spacing2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTokens.fontSizeXs,
          fontWeight: AppTokens.fontWeightBold,
          color: fg,
        ),
      ),
    );
  }
}
