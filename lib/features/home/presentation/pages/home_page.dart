import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/trial_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          userAsync.whenData((user) => user?.avatarUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user!.avatarUrl!),
                  radius: 16,
                )
              : const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 16),
                )).valueOrNull ??
              const SizedBox.shrink(),
          const SizedBox(width: AppTokens.spacing16),
        ],
      ),
      body: Column(
        children: [
          // ── Trial Banner (shows when in trial) ───────────────────────────
          userAsync.when(
            data: (user) => user != null ? TrialBanner(user: user) : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // ── Main Content ────────────────────────────────────────────────
          Expanded(
            child: userAsync.when(
              data: (user) => _HomeContent(userName: user?.fullName),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.spacing16),
      children: [
        // ── Greeting ──────────────────────────────────────────────────────
        Text(
          userName != null ? 'Hello, $userName 👋' : 'Welcome 👋',
          style: context.textTheme.headlineLarge,
        ),
        const SizedBox(height: AppTokens.spacing8),
        Text(
          'What would you like to do today?',
          style: context.textTheme.bodyLarge?.copyWith(
            color: AppTokens.grey500,
          ),
        ),

        const SizedBox(height: AppTokens.spacing32),

        // ── Quick Actions ─────────────────────────────────────────────────
        Text('Quick actions', style: context.textTheme.titleLarge),
        const SizedBox(height: AppTokens.spacing16),

        // TODO: Replace with your product's quick actions
        _QuickActionCard(
          icon: Icons.add_circle_outline,
          title: 'Create new',
          subtitle: 'Add your first item',
          onTap: () {/* Navigate to create */},
        ),
        const SizedBox(height: AppTokens.spacing12),
        _QuickActionCard(
          icon: Icons.list_alt_outlined,
          title: 'View all',
          subtitle: 'Browse your items',
          onTap: () {/* Navigate to list */},
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTokens.spacing16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTokens.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTokens.radiusM),
          ),
          child: Icon(icon, color: AppTokens.primary),
        ),
        title: Text(title, style: context.textTheme.titleMedium),
        subtitle: Text(subtitle, style: context.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
